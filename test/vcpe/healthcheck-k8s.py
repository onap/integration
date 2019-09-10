#! /usr/bin/python

import argparse
import commands
import json
import logging
import subprocess
import sys

def parse_args():
    """
    Parse command line arguments
    :return: arguments
    """
    parser = argparse.ArgumentParser(description='Processing arguments for vCPE healthcheck',formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('--namespace', default="onap",
                             metavar=('<namespace_name>'),
                             help='Namespace name for existing ONAP deployment')
    parser.add_argument('--environment', default="dev",
                             metavar=('<environment_name>'),
                             help='Environment name for existing ONAP deployment visible in <environment_name>-sdnc-sdnc-0 pod name')
    args = parser.parse_args()
    return args


args = parse_args()

namespace = args.namespace
environment = args.environment

print('Checking vGMUX REST API from SDNC')
cmd = 'curl -s -u admin:admin -X GET http://10.0.101.21:8183/restconf/config/ietf-interfaces:interfaces'
ret = commands.getstatusoutput("kubectl -n {0} exec {1}-sdnc-sdnc-0 -- bash -c '{2}'".format(namespace, environment, cmd))
sz = ret[-1].split('\n')[-1]
print(json.dumps(json.loads(sz), indent=4))

print('\n')
print('Checking vBRG REST API from SDNC')
cmd = 'curl -s -u admin:admin -X GET http://10.3.0.2:8183/restconf/config/ietf-interfaces:interfaces'
ret = commands.getstatusoutput("kubectl -n {0} exec {1}-sdnc-sdnc-0 -- bash -c '{2}'".format(namespace, environment, cmd))
sz = ret[-1].split('\n')[-1]
print(json.dumps(json.loads(sz), indent=4))

print('\n')
print('Checking SDNC DB for vBRG MAC address')
cmd = "kubectl -n {0} exec {1}-mariadb-galera-mariadb-galera-0 -- mysql -uroot -psecretpassword sdnctl -e 'select * from DHCP_MAP'".format(namespace, environment)
p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)
(output, error) = p.communicate()
print(output)
