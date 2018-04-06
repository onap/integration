#! /usr/bin/python

import time
import logging
import json
import mysql.connector
import ipaddress
import re
import sys
import base64
from vcpecommon import *
import preload
import vcpe_custom_service


logging.basicConfig(level=logging.INFO, format='%(message)s')

vcpecommon = VcpeCommon()
nodes=['brg', 'bng', 'mux', 'dhcp']
hosts = vcpecommon.get_vm_ip(nodes)
print(json.dumps(hosts, indent=4, sort_keys=True))





