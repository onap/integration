#!/usr/bin/env python

import argparse
import json
from subprocess import Popen,PIPE,STDOUT,check_output,CalledProcessError
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

# config section
kube_cmd = 'kubectl -n {0} exec {1}-sdnc-sdnc-0 -c sdnc -- bash -c '.format(namespace, environment)
curl_check_cmd = 'apk info -e curl'
curl_install_cmd = 'sudo apk add curl'
curl_cmd = 'curl -s -u admin:admin -X GET http://{0}:8183/restconf/config/ietf-interfaces:interfaces'
endpoints = {
    "vGMUX": '10.0.101.21',
    "vBRG": '10.3.0.2'
}
# end of config section

# Install curl command in SDNC container
try:
    check_output(kube_cmd.split() + [curl_check_cmd], stderr=STDOUT)
except CalledProcessError:
    try:
        check_output(kube_cmd.split() + [curl_install_cmd], stderr=STDOUT)
    except CalledProcessError:
        print('Curl package installation failed, exiting.')
        sys.exit(1)
    else:
        print("Curl package was installed in SDNC container")

for ename,eip in endpoints.items():
    print('Checking {0} REST API from SDNC'.format(ename))
    p = Popen(kube_cmd.split() + [curl_cmd.format(eip)], stdout=PIPE, stderr=PIPE)
    (output, error) = p.communicate()
    if p.returncode:
        print(error)
        sys.exit(p.returncode)
    else:
        print(json.dumps(json.loads(output), indent=4))
    print('\n')

print('Checking SDNC DB for vBRG MAC address')
kube_db_cmd = 'kubectl -n {0} exec {1}-mariadb-galera-mariadb-galera-0 -- bash -c'
db_cmd = "mysql -uroot -psecretpassword sdnctl -e 'select * from DHCP_MAP'"
p = Popen(kube_db_cmd.format(namespace, environment).split() + [db_cmd], stdout=PIPE)
(output, error) = p.communicate()
print(output)
