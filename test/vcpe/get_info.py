#!/usr/bin/env python

import logging
import json
from vcpecommon import * # pylint: disable=W0614
import argparse

# Run the script with [-h|--help] to get usage info

logging.basicConfig(level=logging.INFO, format='%(message)s')

parser = argparse.ArgumentParser(formatter_class=
                                 argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('--config',help='Configuration file path',default=None)
args = parser.parse_args()

vcpecommon = VcpeCommon(cfg_file=args.config)
nodes=['brg', 'bng', 'mux', 'dhcp']
hosts = vcpecommon.get_vm_ip(nodes)
print(json.dumps(hosts, indent=4, sort_keys=True))





