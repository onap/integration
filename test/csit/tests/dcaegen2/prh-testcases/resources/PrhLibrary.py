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
        ipv4 = json_to_python["event"]["otherFields"]["pnfOamIpv4Address"]
        ipv6 = json_to_python["event"]["otherFields"]["pnfOamIpv6Address"]
        pnf_name = _create_pnf_name(json_file)
        str_json = '{"pnf-name":"' + pnf_name + '","ipaddress-v4-oam":"' + ipv4 + '","ipaddress-v6-oam":"' + ipv6 + '"}'
        python_to_json = json.dumps(str_json)
        return python_to_json.replace("\\", "")[1:-1]

    @staticmethod
    def create_pnf_name(json_file):
        return _create_pnf_name(json_file)

    @staticmethod
    def stop_aai():
        client = docker.from_env()
        container = client.containers.get('aai_simulator')
        container.stop()


def _create_pnf_name(json_file):
    json_to_python = json.loads(json_file)
    vendor = json_to_python["event"]["otherFields"]["pnfVendorName"]
    serial_number = json_to_python["event"]["otherFields"]["pnfSerialNumber"]
    return vendor[:3].upper() + serial_number
