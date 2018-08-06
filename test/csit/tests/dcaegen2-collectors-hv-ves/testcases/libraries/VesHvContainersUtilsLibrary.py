from time import time

from robot.api import logger
import os.path
import docker
from io import BytesIO
from os.path import basename
from tarfile import TarFile, TarInfo

LOCALHOST = "localhost"


class VesHvContainersUtilsLibrary:

    def get_consul_api_access_url(self, method, image_name, port):
        return self.create_url(
            method,
            self.get_instance_address(image_name, port)
        )

    def get_xnf_sim_api_access_url(self, method, host):
        if is_running_inside_docker():
            return self.create_url(method, host)
        else:
            logger.info("File `/.dockerenv` not found. Assuming local environment and using localhost.")
            port_from_container_name = str(host)[-4:]
            return self.create_url(method, LOCALHOST + ":" + port_from_container_name)

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

def copy_to_container(container_id, filepaths, path='/etc/ves-hv'):
    with create_archive(filepaths) as archive:
        docker.APIClient('unix:///var/run/docker.sock') \
            .put_archive(container=container_id, path=(path), data=archive)


def create_archive(filepaths):
    tarstream = BytesIO()
    tarfile = TarFile(fileobj=tarstream, mode='w')
    for filepath in filepaths:
        file = open(filepath, 'r')
        file_data = file.read()

        tarinfo = TarInfo(name=basename(file.name))
        tarinfo.size = len(file_data)
        tarinfo.mtime = time()

        tarfile.addfile(tarinfo, BytesIO(file_data))

    tarfile.close()
    tarstream.seek(0)
    return tarstream
