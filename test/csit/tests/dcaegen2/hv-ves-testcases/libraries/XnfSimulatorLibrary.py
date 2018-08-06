from VesHvContainersUtilsLibrary import copy_to_container
import HttpRequests
import os
import docker
from robot.api import logger
from time import sleep

XNF_SIMULATOR_NAME = "xNF Simulator"
SIMULATOR_IMAGE_NAME = "onap/ves-hv-collector-xnf-simulator"
SIMULATOR_IMAGE_FULL_NAME = os.getenv("DOCKER_REPO_ADDR") + "/" + SIMULATOR_IMAGE_NAME
certificates_dir_path = os.getenv("WORKSPACE") + "/test/csit/plans/dcaegen2/hv-ves-testsuites/ssl/"
ONE_SECOND_IN_NANOS = 10 ** 9

class XnfSimulatorLibrary:

    def start_xnf_simulators(self, list_of_ports, valid_certs=True):
        logger.info("Creating " + str(len(list_of_ports)) + " xNF Simulator containers")
        logger.info("Using image: " + SIMULATOR_IMAGE_FULL_NAME)
        dockerClient = docker.from_env()
        cert_name_prefix = "" if valid_certs else "invalid_"
        simulators_addresses = self.create_simulators(dockerClient, list_of_ports, cert_name_prefix)
        self.assert_containers_startup_was_successful(dockerClient)
        dockerClient.close()
        return simulators_addresses

    def create_simulators(self, dockerClient, list_of_ports, cert_name_prefix):
        simulators_addresses = []
        for port in list_of_ports:
            container = self.run_simulator(dockerClient, port,
                                           "/etc/ves-hv/" + cert_name_prefix + "client.crt",
                                           "/etc/ves-hv/" + cert_name_prefix + "client.key",
                                           "/etc/ves-hv/" + cert_name_prefix + "trust.crt"
                                           )

            self.copy_required_certificates_into_simulator(container)
            logger.info("Started container: " + container.name + "  " + container.id)
            simulators_addresses.append(container.name + ":" + port)
        return simulators_addresses

    def run_simulator(self, dockerClient, port, client_crt_path, client_key_path, client_trust_store):
        return dockerClient.containers.run(SIMULATOR_IMAGE_FULL_NAME,
                                           command=["--listen-port", port,
                                                    "--ves-host", "ves-hv-collector",
                                                    "--ves-port", "6061",
                                                    "--cert-file", client_crt_path,
                                                    "--private-key-file", client_key_path,
                                                    "--trust-cert-file", client_trust_store
                                                    ],
                                           healthcheck={
                                               "interval": 5 * ONE_SECOND_IN_NANOS,
                                               "timeout": 3 * ONE_SECOND_IN_NANOS,
                                               "retries": 1,
                                               "test": ["CMD", "curl", "--request", "GET",
                                                        "--fail", "--silent", "--show-error",
                                                        "localhost:" + port + "/healthcheck"]
                                           },
                                           detach=True,
                                           network="ves-hv-default",
                                           ports={port + "/tcp": port},
                                           name="ves-hv-collector-xnf-simulator" + port)

    def copy_required_certificates_into_simulator(self, container):
        container.exec_run("mkdir -p /etc/ves-hv")
        copy_to_container(container.id, [
            certificates_dir_path + "client.crt",
            certificates_dir_path + "client.key",
            certificates_dir_path + "trust.crt",
            certificates_dir_path + "invalid_client.crt",
            certificates_dir_path + "invalid_client.key",
            certificates_dir_path + "invalid_trust.crt",
        ])

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

    def stop_and_remove_all_xnf_simulators(self):
        dockerClient = docker.from_env()
        for container in self.get_simulators_list(dockerClient):
            logger.info("Stopping and removing container: " + container.id)
            logger.debug(container.logs())
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


class ContainerException(Exception):
    def __init__(self, message):
        super(ContainerException, self).__init__(message)
