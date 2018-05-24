'''
Created on Apr 27, 2018

@author: mwagner9
'''

import threading
import time

from robot.api import logger

import PrhVariables
import Simulator

st = '{"event":{"correlationID":"NOKQTFCOC540002E", "pnfOamIpv4Address":"10.16.123.234", "pnfOamIpv6Address":"2001:0db8:85a3:0000:0000:8a2e:0370:7334"}}'

class PrhLibrary(object):
    def __init__(self):
        pass

    def setup_dmaap_server(self):
        return _setup(PrhVariables.DMaaPHttpServerThread, 'DMaaP', PrhVariables.DMaaPIsRobotRun, Simulator, 3904)

    def setup_aai_server(self):
        return _setup(PrhVariables.AAIHttpServerThread, 'AAI', PrhVariables.AAIIsRobotRun, Simulator, 3905)

    def shutdown_dmaap_server(self):
        return _shutdown(PrhVariables.DMaaPHTTPD, 'DMaaP')

    def shutdown_aai_server(self):
        return _shutdown(PrhVariables.AAIHTTPD, 'AAI')

    def is_json_empty(self, response):
        logger.info("Enter is_json_empty: response.text: " + response.text)
        if response.text is None or len(response.text) < 2:
            return 'True'
        return 'False'

    def dmaap_collectorTimeStamp_receive(self, search, response):
        return _find_element(search, response)

    def AAI_Ipv4_receive(self, search, response):
        return _find_element(search, response)

    def AAI_Ipv6_receive(self, search, response):
        return _find_element(search, response)

    def check_pnf_ready(self):
        if st in Simulator.prh_ready:
            return 'true'
        return 'false'

def _setup(serverthread, servername, isrobotrun, module, portNum):
    if serverthread is not None:
        logger.console('{} Mockup Sever started'.format(servername))
        return "true"

    isrobotrun = True

    module_handler = module.AAIHandler if servername is 'AAI' else module.DMaaPHandler 

    module.run_server(module_handler, portNum)
    try:
        serverthread = threading.Thread(name='{}_HTTPServer'.format(servername), target=module.Httpd.serve_forever)
        serverthread.start()
        logger.console('{}  Mockup Sever started'.format(servername))
        time.sleep(2)
        return "true"
    except Exception as e:
        print (str(e))
        return "false"

def _shutdown(server, name):
    if server is not None:
        server.shutdown()
        logger.console("{} Server shut down".format(name))
        time.sleep(3)
        return "true"
    else:
        return "false"

def _find_element(search, response):
    while response is not None:
        json_data = str(response)
        if search in json_data:
            return 'true'
    return 'false'

if __name__ == '__main__':
    lib = PrhLibrary()
    ret = lib.setup_dmaap_server()
    print ret
    ret = lib.setup_aai_server()
    print ret
    time.sleep(10)
