from robot.api import logger
import HttpRequests

CONSUL_NAME = "Consul"

class ConsulLibrary:

    def publish_hv_ves_configuration_in_consul(self, consul_url, consul_configuration_filepath):
        logger.info("Reading consul configuration file from: " + consul_configuration_filepath)
        file = open(consul_configuration_filepath, "rb")
        data = file.read()
        file.close()

        logger.info("PUT at: " + consul_url)
        resp = HttpRequests.session_without_env().put(consul_url, data=data, timeout=5)
        HttpRequests.checkStatusCode(resp.status_code, CONSUL_NAME)