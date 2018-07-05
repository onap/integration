import docker

class PrhLibrary(object):

    def __init__(self):
        pass

    def check_for_log(self, search_for):
        client = docker.from_env()
        container = client.containers.get('prh')
        for line in container.logs(stream=True):
            if search_for in line.strip():
                return True
        else:
            return False
