import HttpRequests
from robot.api import logger

DCAE_APP_NAME = "DCAE App"

class DcaeAppSimulatorLibrary:

    def configure_dcae_app_simulator_to_consume_messages_from_topics(self, app_url, topics):
        logger.info("PUT at: " + app_url)
        resp = HttpRequests.session_without_env().put(app_url, data={'topics': topics}, timeout=5)
        HttpRequests.checkStatusCode(resp.status_code, DCAE_APP_NAME)

    def assert_DCAE_app_consumed(self, app_url, expected_messages_amount):
        logger.info("GET at: " + app_url)
        resp = HttpRequests.session_without_env().get(app_url, timeout=5)
        HttpRequests.checkStatusCode(resp.status_code, DCAE_APP_NAME)

        assert resp.content == expected_messages_amount, \
            "Messages consumed by simulator: " + resp.content + " expecting: " + expected_messages_amount


    def reset_DCAE_app_simulator(self, app_url):
        logger.info("DELETE at: " + app_url)
        resp = HttpRequests.session_without_env().delete(app_url, timeout=5)
        HttpRequests.checkStatusCode(resp.status_code, DCAE_APP_NAME)

