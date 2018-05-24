'''
Created on May 10, 2018

@author: mwagner9
'''

import BaseHTTPServer
import re
import sys

from robot.api import logger

import PrhVariables

Httpd = None
prh_ready = ''

class BaseHandler(BaseHTTPServer.BaseHTTPRequestHandler, object):
    def do_GET(self, param1, param2):
        """Serve a GET request."""
        #prepare GET response
        logger.console(self.raw_requestlinel)
        json_string = param1
        if re.search(param2, self.path) is not None:
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            self.wfile.write(json_string)

class AAIHandler(BaseHandler):
    def do_PATCH(self):
        #prepare PATCH response
        logger.console('========')
        logger.console(self.raw_requestline)
        logger.console('========')
        if re.search('/aai/v12/network/pnfs/pnf/NOKQTFCOC540002E', self.path)is not None:
            st = '{"ipaddress-v6-oam": "2001:0db8:85a3:0000:0000:8a2e:0370:7334","ipaddress-v4-oam": "11.22.33.156"}'
            logger.console('========')
            logger.console(self.raw_requestline)
            logger.console('========')
            self.send_response(200)

    def do_GET(self):
        param1 = '{"pnf-name":"NOKQTFCOC540002E", "pnf-id":"NOKQTFCOC540002E","ipaddress-v4-oam":"10.16.123.234","ipaddress-v6-oam":"2001:0db8:85a3:0000:0000:8a2e:0370:7334"}'
        param2 = '/aai/v12/network/pnfs/pnf/NOKQTFCOC540002E'
        super(self.__class__, self).do_GET(param1, param2)

class DMaaPHandler(BaseHandler):
    def do_GET(self): 
        param1 = '{"event": {"commonEventHeader": {"sourceId":"QTFCOC540002E", "startEpochMicrosec":1519837825682, "eventId":"QTFCOC540002E-reg", "nfcNamingCode":"5DU", "internalHeaderFields":{"collectorTimeStamp":"Fri, 04 27 2018 09:01:10 GMT"}, "eventType":"pnfRegistration", "priority":"Normal", "version":3, "reportingEntityName":"5GRAN_DU", "sequence":0, "domain":"other", "lastEpochMicrosec":1519837825682, "eventName":"pnfRegistration_5GDU", "sourceName":"5GRAN_DU", "nfNamingCode":"5GRAN"}, "otherFields": {"pnfLastServiceDate":1517206400, "pnfOamIpv6Address":"2001:0db8:85a3:0000:0000:8a2e:0370:7334", "pnfVendorName":"Nokia", "pnfModelNumber":"AJ02", "pnfFamily":"BBU", "pnfType":"AirScale", "otherFieldsVersion":1, "pnfOamIpv4Address":"10.16.123.234", "pnfSoftwareVersion":"v4.5.0.1", "pnfSerialNumber":"QTFCOC540002E", "pnfManufactureDate":1516406400}}}'
        param2 = '/events/unauthenticated.SEC_OTHER_OUTPUT/OpenDCAE-c12/c12'
        super(self.__class__, self).do_GET(param1, param2)

    def do_POST(self):
        #Prepare POST response
        logger.console('========')
        logger.console(self.raw_requestline)
        logger.console('========')
        if re.search('/events/unauthenticated.PNF_READY', self.path) is not None:
            global prh_ready
            prh_ready = '{"event":{"correlationID":"NOKQTFCOC540002E", "pnfOamIpv4Address":"10.16.123.234", "pnfOamIpv6Address":"2001:0db8:85a3:0000:0000:8a2e:0370:7334"}}'
            self.send_response(200)

def run_server(HandlerClass, port, ServerClass = BaseHTTPServer.HTTPServer, protocol="HTTP/1.0"):
    server_address = ('', port)

    HandlerClass.protocol_version = protocol
    httpd = ServerClass(server_address, HandlerClass)
    
    global Httpd
    Httpd = httpd  
    if HandlerClass is DMaaPHandler:
        PrhVariables.DMaaPHTTPD = httpd
    else:
        PrhVariables.AAIHTTPD = httpd

    sa = httpd.socket.getsockname()
    print "Serving HTTP on", sa[0], "port", sa[1], "..."

def _main_ (HandlerClass, port, ServerClass = BaseHTTPServer.HTTPServer, protocol="HTTP/1.0"):
    server_address = ('', port)

    HandlerClass.protocol_version = protocol
    httpd = ServerClass(server_address, HandlerClass)

    sa = httpd.socket.getsockname()
    print "Serving HTTP on", sa[0], "port", sa[1], "..."
    httpd.serve_forever()
    
if __name__ == '__main__':
    _main_(DMaaPHandler, 3904)
