#! /usr/bin/python

import logging
import json
from vcpecommon import *
import commands
import sys

if len(sys.argv) <2:
   print('namespace not provided')
   print('Usage: healthcheck-k8s.py onap')
   sys.exit()

namespace=sys.argv[1]

logging.basicConfig(level=logging.INFO, format='%(message)s')
common = VcpeCommon()

print('Checking vGMUX REST API from SDNC')
cmd = 'curl -u admin:admin -X GET http://10.0.101.21:8183/restconf/config/ietf-interfaces:interfaces'
ret = commands.getstatusoutput("kubectl -n {0} exec dev-sdnc-sdnc-0 -- bash -c '{1}'".format(namespace,cmd))
sz = ret[-1].split('\n')[-1]
print('\n')
print(sz)

print('Checking vBRG REST API from SDNC')
cmd = 'curl -u admin:admin -X GET http://10.3.0.2:8183/restconf/config/ietf-interfaces:interfaces'
ret = commands.getstatusoutput("kubectl -n {0} exec dev-sdnc-sdnc-0 -- bash -c '{1}'".format(namespace,cmd))
sz = ret[-1].split('\n')[-1]
print('\n')
print(sz)

print('Checking SDNC DB for vBRG MAC address')
mac = common.get_brg_mac_from_sdnc()
print(mac)

