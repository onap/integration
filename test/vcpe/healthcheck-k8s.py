#! /usr/bin/python

import logging
import json
import commands
import sys
import subprocess

if len(sys.argv) <2:
   print('namespace not provided')
   print('Usage: healthcheck-k8s.py onap')
   sys.exit()

namespace=sys.argv[1]

print('Checking vGMUX REST API from SDNC')
cmd = 'curl -s -u admin:admin -X GET http://10.0.101.21:8183/restconf/config/ietf-interfaces:interfaces'
ret = commands.getstatusoutput("kubectl -n {0} exec dev-sdnc-sdnc-0 -- bash -c '{1}'".format(namespace,cmd))
sz = ret[-1].split('\n')[-1]
print(json.dumps(json.loads(sz), indent=4))

print('\n')
print('Checking vBRG REST API from SDNC')
cmd = 'curl -s -u admin:admin -X GET http://10.3.0.2:8183/restconf/config/ietf-interfaces:interfaces'
ret = commands.getstatusoutput("kubectl -n {0} exec dev-sdnc-sdnc-0 -- bash -c '{1}'".format(namespace,cmd))
sz = ret[-1].split('\n')[-1]
print(json.dumps(json.loads(sz), indent=4))

print('\n')
print('Checking SDNC DB for vBRG MAC address')
cmd = "kubectl -n onap exec dev-sdnc-sdnc-db-0 -c sdnc-db  -- mysql -usdnctl -pgamma sdnctl -e 'select * from DHCP_MAP;'"
p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
(output, error) = p.communicate()
print(output)

