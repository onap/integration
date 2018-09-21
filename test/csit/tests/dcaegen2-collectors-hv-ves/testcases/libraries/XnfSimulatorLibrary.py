import HttpRequests
import os
import docker
from robot.api import logger
from time import sleep

XNF_SIMULATOR_NAME = "xNF Simulator"
SIMULATOR_IMAGE_NAME = "onap/org.onap.dcaegen2.collectors.hv-ves.hv-collector-xnf-simulator"
SIMULATOR_IMAGE_FULL_NAME = os.getenv("DOCKER_REGISTRY_PREFIX") + SIMULATOR_IMAGE_NAME + ":latest"
WORKSPACE_ENV = os.getenv("WORKSPACE")
certificates_dir_path = WORKSPACE_ENV + "/test/csit/plans/dcaegen2-collectors-hv-ves/testsuites/ssl/"
collector_certs_lookup_dir = "/etc/ves-hv/"
ONE_SECOND_IN_NANOS = 10 ** 9


class XnfSimulatorLibrary:

    def start_xnf_simulators(self, list_of_ports,
                             should_use_valid_certs=True,
                             should_disable_ssl=False,
                             should_connect_to_unencrypted_hv_ves=False):
        logger.info("Creating " + str(len(list_of_ports)) + " xNF Simulator containers")
        dockerClient = docker.from_env()

        self.pullImageIfAbsent(dockerClient)
        logger.info("Using image: " + SIMULATOR_IMAGE_FULL_NAME)

        simulators_addresses = self.create_containers(dockerClient,
                                                      list_of_ports,
                                                      should_use_valid_certs,
                                                      should_disable_ssl,
                                                      should_connect_to_unencrypted_hv_ves)

        self.assert_containers_startup_was_successful(dockerClient)
        dockerClient.close()
        return simulators_addresses

    def pullImageIfAbsent(self, dockerClient):
        try:
            dockerClient.images.get(SIMULATOR_IMAGE_FULL_NAME)
        except:
            logger.console("Image " + SIMULATOR_IMAGE_FULL_NAME + " will be pulled from repository. "
                                                                  "This can take a while.")
            dockerClient.images.pull(SIMULATOR_IMAGE_FULL_NAME)

    def create_containers(self,
                          dockerClient,
                          list_of_ports,
                          should_use_valid_certs,
                          should_disable_ssl,
                          should_connect_to_unencrypted_hv_ves):
        simulators_addresses = []
        for port in list_of_ports:
            xnf = XnfSimulator(port, should_use_valid_certs, should_disable_ssl, should_connect_to_unencrypted_hv_ves)
            container = self.run_simulator(dockerClient, xnf)
            logger.info("Started container: " + container.name + "  " + container.id)
            simulators_addresses.append(container.name + ":" + xnf.port)
        return simulators_addresses

    def run_simulator(self, dockerClient, xnf):
        xNF_startup_command = xnf.get_startup_command()
        xNF_healthcheck_command = xnf.get_healthcheck_command()
        port = xnf.port
        logger.info("Startup command: " + str(xNF_startup_command))
        logger.info("Healthcheck command: " + str(xNF_healthcheck_command))
        return dockerClient.containers.run(SIMULATOR_IMAGE_FULL_NAME,
                                           command=xNF_startup_command,
                                           healthcheck=xNF_healthcheck_command,
                                           detach=True,
                                           network="ves-hv-default",
                                           ports={port + "/tcp": port},
                                           volumes=self.container_volumes(),
                                           name=xnf.container_name_prefix + port)

    def container_volumes(self):
        return {certificates_dir_path: {"bind": collector_certs_lookup_dir, "mode": 'rw'}}

    def assert_containers_startup_was_successful(self, dockerClient):
        checks_amount = 6
        check_interval_in_seconds = 5
        for _ in range(checks_amount):
            sleep(check_interval_in_seconds)
            all_containers_healthy = True
            for container in self.get_simulators_list(dockerClient):
                all_containers_healthy = all_containers_healthy and self.is_container_healthy(container)
            if (all_containers_healthy):
                return
        raise ContainerException("One of xNF simulators containers did not pass the healthcheck.")

    def is_container_healthy(self, container):
        container_health = container.attrs['State']['Health']['Status']
        return container_health == 'healthy' and container.status == 'running'

    def stop_and_remove_all_xnf_simulators(self, suite_name):
        dockerClient = docker.from_env()
        for container in self.get_simulators_list(dockerClient):
            logger.info("Stopping and removing container: " + container.id)
            log_filename = WORKSPACE_ENV + "/archives/containers_logs/" + \
                           suite_name.split(".")[-1] + "_" + container.name + ".log"
            file = open(log_filename, "w+")
            file.write(container.logs())
            file.close()
            container.stop()
            container.remove()
        dockerClient.close()

    def get_simulators_list(self, dockerClient):
        return dockerClient.containers.list(filters={"ancestor": SIMULATOR_IMAGE_FULL_NAME}, all=True)

    def send_messages(self, simulator_url, message_filepath):
        logger.info("Reading message to simulator from: " + message_filepath)

        file = open(message_filepath, "rb")
        data = file.read()
        file.close()

        logger.info("POST at: " + simulator_url)
        resp = HttpRequests.session_without_env().post(simulator_url, data=data, timeout=5)
        HttpRequests.checkStatusCode(resp.status_code, XNF_SIMULATOR_NAME)


class XnfSimulator:
    container_name_prefix = "ves-hv-collector-xnf-simulator"

    def __init__(self,
                 port,
                 should_use_valid_certs,
                 should_disable_ssl,
                 should_connect_to_unencrypted_hv_ves):
        self.port = port
        cert_name_prefix = "" if should_use_valid_certs else "untrusted"
        certificates_path_with_file_prefix = collector_certs_lookup_dir + cert_name_prefix
        self.key_store_path = certificates_path_with_file_prefix + "client.p12"
        self.trust_store_path = certificates_path_with_file_prefix + "trust.p12"
        self.sec_store_passwd = "onaponap"
        self.disable_ssl = should_disable_ssl
        self.hv_collector_host = "unencrypted-ves-hv-collector" \
            if should_connect_to_unencrypted_hv_ves else "ves-hv-collector"

    def get_startup_command(self):
        startup_command = ["--listen-port", self.port,
                           "--ves-host", self.hv_collector_host,
                           "--ves-port", "6061",
                           "--key-store", self.key_store_path,
                           "--trust-store", self.trust_store_path,
                           "--key-store-password", self.sec_store_passwd,
                           "--trust-store-password", self.sec_store_passwd
                           ]
        if self.disable_ssl:
            startup_command.append("--ssl-disable")
        return startup_command

    def get_healthcheck_command(self):
        return {
            "interval": 5 * ONE_SECOND_IN_NANOS,
            "timeout": 3 * ONE_SECOND_IN_NANOS,
            "retries": 1,
            "test": ["CMD", "curl", "--request", "GET",
                     "--fail", "--silent", "--show-error",
                     "localhost:" + self.port + "/healthcheck"]
        }


class ContainerException(Exception):
    def __init__(self, message):
        super(ContainerException, self).__init__(message)
