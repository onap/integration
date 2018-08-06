from time import time

from robot.api import logger
import os.path

LOCALHOST = "localhost"


class VesHvContainersUtilsLibrary:

    def get_consul_api_access_url(self, method, image_name, port):
        return self.create_url(
            method,
            self.get_instance_address(image_name, port)
        )

    def get_dcae_app_api_access_url(self, method, image_name, port):
        return self.create_url(
            method,
            self.get_instance_address(image_name, port)
        )

    def get_instance_address(self, image_name, port):
        if is_running_inside_docker():
            return image_name + ":" + port
        else:
            logger.info("File `/.dockerenv` not found. Assuming local environment and using localhost.")
            return LOCALHOST + ":" + port

    def create_url(self, method, host_address):
        return method + host_address

def is_running_inside_docker():
    return os.path.isfile("/.dockerenv")
