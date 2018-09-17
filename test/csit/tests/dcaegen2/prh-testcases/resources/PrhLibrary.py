import json

import docker


class PrhLibrary(object):

    def __init__(self):
        pass

    @staticmethod
    def check_for_log(search_for):
        client = docker.from_env()
        container = client.containers.get('prh')
        for line in container.logs(stream=True):
            if search_for in line.strip():
                return True
        else:
            return False

    @staticmethod
    def create_pnf_ready_notification(json_file):
        json_to_python = json.loads(json_file)
        ipv4 = json_to_python["event"]["pnfRegistrationFields"]["oamV4IpAddress"]
        ipv6 = json_to_python["event"]["pnfRegistrationFields"]["oamV6IpAddress"]
        correlationId = json_to_python["event"]["commonEventHeader"]["sourceName"]
        str_json = '{"correlationId":"' + correlationId + '","ipaddress-v4-oam":"' + ipv4 + '","ipaddress-v6-oam":"' + ipv6 + '"}'
        python_to_json = json.dumps(str_json)
        return python_to_json.replace("\\", "")[1:-1]

    @staticmethod
    def create_pnf_name(json_file):
        json_to_python = json.loads(json_file)
        correlationId = json_to_python["event"]["commonEventHeader"]["sourceName"]
        return correlationId

    @staticmethod
    def stop_aai():
        client = docker.from_env()
        container = client.containers.get('aai_simulator')
        container.stop()

    def create_invalid_notification(self, json_file):
        return self.create_pnf_ready_notification(json_file).replace("\":", "\": ")\
            .replace("ipaddress-v4-oam", "oamV4IpAddress").replace("ipaddress-v6-oam", "oamV6IpAddress")\
            .replace("}", "\\n}")
