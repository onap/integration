#!/usr/bin/env python3
import argparse
import sys
from subprocess import *
from subprocess import STDOUT
import subprocess
import ipaddress
import time

parser = argparse.ArgumentParser()
parser.add_argument(
    '--bootstrap',
    help='Bootstrapping the system',
)

parser.add_argument(
    '--ipves',
    help='IP of the VES collector',
)

parser.add_argument(
    '--ipstart',
    help='IP address range beginning',
)

parser.add_argument(
    '--clean',
    action='store_true',
    help='Cleaning work-dirs',
)

parser.add_argument(
    '--start',
    help='Starting instances',
)

parser.add_argument(
    '--status',
    help='Status',
)

parser.add_argument(
    '--stop',
    help='Stopping instances',
)

args = parser.parse_args()

if args.bootstrap and args.ipstart and args.ipves:
    print("Bootstrap:")

    for i in range(int(args.bootstrap)):
        print("PNF simulator instance: " + str(i) + ".")

        ip_subnet = ipaddress.ip_address(args.ipstart) + int(0 + (i * 16))
        print("\tIp Subnet:" + str(ip_subnet))
        # The IP ranges are in distance of 16 compared to each other.
        # This is matching the /28 subnet mask used in the dockerfile inside.

        ip_gw = ipaddress.ip_address(args.ipstart) + int(1 + (i * 16))
        print("\tIP Gateway:" + str(ip_gw))

        IpPnfSim = ipaddress.ip_address(args.ipstart) + int(2 + (i * 16))
        print("\tIp Pnf SIM:" + str(IpPnfSim))

        IpFtps = ipaddress.ip_address(args.ipstart) + int(3 + (i * 16))
        print("\tIp Ftps: " + str(IpFtps))

        IpSftp = ipaddress.ip_address(args.ipstart) + int(4 + (i * 16))
        print("\tIp Sftp:" + str(IpSftp))

        foldername = "pnf-sim-lw-" + str(i)
        completed = subprocess.run('mkdir ' + foldername, shell=True)
        print('\tCreating folder:', completed.stdout)
        completed = subprocess.run(
            'cp -r pnf-sim-lightweight/* ' +
            foldername,
            shell=True)
        print('\tCloning folder:', completed.stdout)

        composercmd = "./simulator.sh compose " +\
            str(ip_gw) + " " +\
            str(ip_subnet) + " " +\
            str(i) + " " +\
            str(args.ipves) + " " +\
            str(IpPnfSim) + " " +\
            str(IpFtps) + " " +\
            str(IpSftp)

        completed = subprocess.run(
            'set -x; cd ' +
            foldername +
            '; ' +
            composercmd,
            shell=True)
        print('Cloning:', completed.stdout)

    sys.exit()

if args.clean:
    completed = subprocess.run('rm -rf ./pnf-sim-lw-*', shell=True)
    print('Deleting:', completed.stdout)
    sys.exit()

if args.start:

    for i in range(int(args.start)):
        foldername = "pnf-sim-lw-" + str(i)

        completed = subprocess.run(
            'set -x ; cd ' +
            foldername +
            "; bash -x ./simulator.sh start",
            shell=True)
        print('Starting:', completed.stdout)

        time.sleep(5)

if args.status:

    for i in range(int(args.status)):
        foldername = "pnf-sim-lw-" + str(i)

        completed = subprocess.run(
            'cd ' +
            foldername +
            "; ./simulator.sh status",
            shell=True)
        print('Status:', completed.stdout)

if args.stop:
    for i in range(int(args.stop)):
        foldername = "pnf-sim-lw-" + str(i)

        completed = subprocess.run(
            'cd ' +
            foldername +
            "; ./simulator.sh stop",
            shell=True)
        print('Stopping:', completed.stdout)

else:
    print("No instruction was defined")
    sys.exit()
