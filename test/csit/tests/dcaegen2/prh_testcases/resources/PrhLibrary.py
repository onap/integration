import docker

class PrhLibrary(object):
    
    def __init__(self):
        pass

    def check_log_for_missing_IP(self):
        client = docker.from_env()
        container = client.containers.get('prh')
        for line in container.logs(stream=True):
            if "org.onap.dcaegen2.services.prh.exceptions.DmaapNotFoundException: IPV4 and IPV6 are empty" in line.strip():
                return True
        else:
            return False