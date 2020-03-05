#!/usr/bin/env python
"""
This script attempts to probe an ONAP deployment in a Kubernetes cluster on an OpenStack stack
and extract all pods and corresponding docker image versions along with some of the tool versions utilised.
"""

import os
import sys
import subprocess
import argparse
import logging

OPENSTACK_GET_SERVER_IPS = 'openstack server list --name "^(%s-).*" -c Name -c Networks -f value --sort-column Name'

SSH_CMD_TEMPLATE = 'ssh -o StrictHostKeychecking=no -i %s ubuntu@%s "sudo su -c \\"%s\\""'

KUBECTL_GET_ALL_POD_IMAGES_AND_SHAS = 'kubectl get pods --all-namespaces -o=jsonpath=\'{range .items[*]}' \
                                      '{\\\\\\"\\n\\\\\\"}{.metadata.name}{\\\\\\":::\\\\\\"}' \
                                      '{range .status.containerStatuses[*]}{.image}{\\\\\\"___\\\\\\"}' \
                                      '{.imageID}{\\\\\\" \\\\\\"}{end}{end}{\\\\\\"\\n\\\\\\"}\''

DOCKER_INSPECT = 'docker inspect --format=\'{{index .RepoTags 0}}{{\\\\\\" \\\\\\"}}{{index .RepoDigests 0}}\' ' \
                 '\$(docker images -q | uniq| tr \'\n\' \' \')'

KUBECTL_VERSION = 'kubectl version'
DOCKER_VERSION = 'docker --version'

local_registry = ""

logging.basicConfig(level=logging.DEBUG, format='%(message)s')
file_log = logging.FileHandler(filename='onap-probe-report.txt', mode='w')
file_log.setLevel(logging.INFO)
formatter = logging.Formatter('%(message)s')
file_log.setFormatter(formatter)
logging.getLogger('').addHandler(file_log)


class CommandResult(object):
    def __init__(self, exit_code, stdout, stderr):
        self.exit_code = exit_code
        self.stdout = stdout
        self.stderr = stderr


def run_command_or_exit(command, message=""):
    if message:
        logging.debug(message)
    logging.debug('cmd> ' + command)

    child = subprocess.Popen(command, stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE, shell=True)
    result = child.communicate()

    cmd_result = CommandResult(child.returncode,
                               result[0].strip(), result[1].strip())

    if cmd_result.exit_code:
        logging.error("exit_code: '%d', stdout: '%s', stderr: '%s'" %
                      (cmd_result.exit_code, cmd_result.stdout, cmd_result.stderr))
        sys.exit(1)

    return cmd_result


class OpenStackK8sCluster(object):
    def __init__(self, stack_name, identity_file):
        self.stack_name = stack_name
        self.identity_file = identity_file
        self.servers = {}
        self.vm_docker_images = set()
        self.kubectl_version = 'unknown'
        self.docker_version = 'unknown'

        response = run_command_or_exit(OPENSTACK_GET_SERVER_IPS % stack_name,
                                       "Get all stack servers and ip addressed using stack name").stdout
        for line in response.split('\n'):
            parts = line.split()
            self.servers[parts[0].replace(stack_name+'-', "")] = parts[2]

    def __str__(self):
        desc = "Stack name: " + self.stack_name + '\n'
        for key, value in sorted(self.servers.items()):
            desc += "  " + key + " : " + value + "\n"
        return desc.strip()

    def get_stack_name(self):
        return self.stack_name

    def get_identity_file(self):
        return self.identity_file

    def get_nfs_ip_address(self):
        return self.servers['nfs']

    def get_worker_nodes(self):
        return [value for key, value in self.servers.items() if 'k8s-' in key.lower()]

    def get_orchestrators(self):
        return [value for key, value in self.servers.items() if 'orch-' in key.lower()]

    def determine_docker_images_on_vms(self):
        for node_ip in self.get_worker_nodes() + self.get_orchestrators():
            command = SSH_CMD_TEMPLATE % (self.get_identity_file(), node_ip, DOCKER_INSPECT)
            vm_inspect_results = run_command_or_exit(command, "Examine server and list docker images").stdout

            for inspect_line in vm_inspect_results.split('\n'):
                name_tag, name_digest = inspect_line.split(' ')
                name, tag = name_tag.rsplit(':', 1)
                digest = name_digest.split('sha256:')[1]
                if local_registry:
                    name = name.replace(local_registry + "/", "")
                self.vm_docker_images.add((name, tag, digest))

    def get_docker_images_on_vms(self):
        return self.vm_docker_images

    def get_number_of_vm_docker_images(self):
        return len(self.vm_docker_images)

    def determine_kubectl_version(self):
        command = SSH_CMD_TEMPLATE % (self.get_identity_file(), self.get_nfs_ip_address(), KUBECTL_VERSION)
        self.kubectl_version = run_command_or_exit(command, "Examine nfs vm to determine kubectl version").stdout

    def get_kubectl_version(self):
        return self.kubectl_version

    def determine_docker_version(self):
        command = SSH_CMD_TEMPLATE % (self.get_identity_file(), self.get_worker_nodes()[0], DOCKER_VERSION)
        self.docker_version = run_command_or_exit(command, "Examine worker node to determine docker version").stdout

    def get_docker_version(self):
        return self.docker_version


class OnapDeployment(object):
    def __init__(self, openstack_stack):
        self.stack = openstack_stack
        self.raw = ""
        self.pods = []
        self.unique_images = set()

    def dig(self):
        command = SSH_CMD_TEMPLATE % (self.stack.get_identity_file(), self.stack.get_nfs_ip_address(),
                                      KUBECTL_GET_ALL_POD_IMAGES_AND_SHAS)
        self.raw = run_command_or_exit(command, "Use kubectl to retrieve all pods and pod images in K8S cluster").stdout

        for row in self.raw.strip().split("\n"):
            self.pods.append(Pod(row))

        for pod in self.pods:
            for image in pod.get_images():
                self.unique_images.add(image)

    def __str__(self):
        desc = "Pods and docker images:\n"
        for pod in sorted(self.pods):
            desc += str(pod)
        return desc.strip()

    def get_number_of_pods(self):
        return len(self.pods)

    def get_docker_images(self):
        return sorted(self.unique_images)

    def get_number_of_unique_docker_images(self):
        return len(self.unique_images)

    def get_number_of_docker_images(self):
        images = []
        for pod in self.pods:
            for image in pod.get_images():
                images.append(image)
        return len(images)


class Pod(object):
    def __init__(self, data):
        self.name, images = data.strip().split(":::")
        self.shas_images = {}
        for item in images.split(" "):
            image_raw, sha_raw = item.split("___")
            if local_registry:
                image_raw = image_raw.replace(local_registry + "/", "")
            if "sha256:" in images:
                self.shas_images[sha_raw.split("sha256:")[1]] = image_raw

    def get_images(self):
        return self.shas_images.values()

    def __cmp__(self, other):
        return cmp(self.name, other.name) # pylint: disable=E0602

    def __str__(self):
        desc = self.name + "\n"
        for key, value in sorted(self.shas_images.items(), key=lambda x: x[1]):
            desc += "        " + value + ", " + key + "\n"
        return desc


def main():
    # Disable output buffering to receive the output instantly
    sys.stdout = os.fdopen(sys.stdout.fileno(), "w", 0)
    sys.stderr = os.fdopen(sys.stderr.fileno(), "w", 0)

    help_desc = "Script to probe an ONAP k8s cluster on an OpenStack stack and report back information on the " \
                "stack vms, all pods and corresponding docker image versions/digests and some of the tool versions " \
                "utilised."
    parser = argparse.ArgumentParser(description=help_desc)
    parser.add_argument("-s", "--stack-name", dest="stack_name",
                        help="OpenStack stack name used by this ONAP deployment",
                        metavar="STACKNAME", required=True)
    parser.add_argument("-i", "--identity_file", dest="identity_file",
                        help="OpenStack identity file to be used by ssh to access servers",
                        metavar="IDENTITY-FILE", required=True)
    parser.add_argument("-r", "--registry", dest="registry",
                        help="Local registry used to serve docker images which should be " +
                             " stripped from any image names in the script output",
                        metavar="REGISTRY", required=False)
    args = parser.parse_args()
    if args.registry:
        global local_registry
        local_registry = args.registry

    openstack_k8s = OpenStackK8sCluster(args.stack_name, args.identity_file)
    openstack_k8s.determine_kubectl_version()
    openstack_k8s.determine_docker_version()
    openstack_k8s.determine_docker_images_on_vms()

    onap_dep = OnapDeployment(openstack_k8s)
    onap_dep.dig()

    logging.info('\n%s\n' % openstack_k8s)
    logging.info("number of pods: %d" % onap_dep.get_number_of_pods())
    logging.info("number of docker images in pods: %d" % onap_dep.get_number_of_docker_images())
    logging.info("number of unique docker images in pods: %d" % onap_dep.get_number_of_unique_docker_images())
    logging.info("number of unique docker images on vms: %d" % openstack_k8s.get_number_of_vm_docker_images())
    logging.info("docker version:\n%s" % openstack_k8s.get_docker_version())
    logging.info("kubectl version:\n%s" % openstack_k8s.get_kubectl_version())

    logging.info("\n%s\n" % onap_dep)

    logging.info("<image-name>,<image-version>,<image-digest>")
    for entry in sorted(openstack_k8s.get_docker_images_on_vms()):
        logging.info('%s,%s,%s' % (entry[0], entry[1], entry[2]))


if __name__ == "__main__":
    main()
