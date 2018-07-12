import json

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

    def create_pnf_ready_notification(self, json_file):
        jsonToPython = json.loads(json_file)
        ipv4 = jsonToPython["event"]["otherFields"]["pnfOamIpv4Address"]
        ipv6 = jsonToPython["event"]["otherFields"]["pnfOamIpv6Address"]
        pnfName = _create_pnf_name(json_file)
        strJson = '{"pnf-name":"' + pnfName + '","ipaddress-v4-oam":"' + ipv4 + '","ipaddress-v6-oam":"' + ipv6 +'"}'
        pythonToJson = json.dumps(strJson)
        return pythonToJson.replace("\\", "")[1:-1]

    def create_pnf_name(self, json_file):
        return _create_pnf_name(json_file)

def _create_pnf_name(json_file):
    jsonToPython = json.loads(json_file)
    vendor = jsonToPython["event"]["otherFields"]["pnfVendorName"]
    serialNumber = jsonToPython["event"]["otherFields"]["pnfSerialNumber"]
    return vendor[:3].upper() + serialNumber
