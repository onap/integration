#!/usr/bin/env python3
import argparse
import sys
import subprocess
import ipaddress
import time
from requests import get
from requests.exceptions import MissingSchema, InvalidSchema, InvalidURL, ConnectionError, ConnectTimeout

def validate_url(url):
    '''Helper function to perform --urlves input param validation'''
    try:
        get(url, timeout=0.001)
    except (MissingSchema, InvalidSchema, InvalidURL):
        raise argparse.ArgumentTypeError(f'{url} is not a valid URL')
    except (ConnectionError, ConnectTimeout):
        pass
    return url

def validate_ip(ip):
    '''Helper function to validate input param is a vaild IP address'''
    try:
        ip_valid = ipaddress.ip_address(ip)
    except ValueError:
        raise argparse.ArgumentTypeError(f'{ip} is not a valid IP address')
    else:
        return ip_valid

parser = argparse.ArgumentParser()
parser.add_argument('--bootstrap', help='Bootstrap the system')
parser.add_argument('--trigger', help='Trigger one single VES event from each simulator')
parser.add_argument('--triggerstart', help='Trigger only a subset of the simulators (note --triggerend)')
parser.add_argument('--triggerend', help='Last instance to trigger')
parser.add_argument('--urlves', help='URL of the VES collector')
parser.add_argument('--ipfileserver', help='Visible IP of the file server (SFTP/FTPS) to be included in the VES event')
parser.add_argument('--typefileserver', help='Type of the file server (SFTP/FTPS) to be included in the VES event')
parser.add_argument('--ipstart', help='IP address range beginning')
parser.add_argument('--clean', action='store_true', help='Clean work-dirs')
parser.add_argument('--start', help='Start instances')
parser.add_argument('--status', help='Status')
parser.add_argument('--stop', help='Stop instances')

args = parser.parse_args()

if args.bootstrap and args.ipstart and args.urlves:
    print("Bootstrap:")

    start_port=2000
    ftps_pasv_port_start=8000
    ftps_pasv_port_num_of_ports=10

    ftps_pasv_port_end=ftps_pasv_port_start + ftps_pasv_port_num_of_ports


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

        IpFileServer = args.ipfileserver
        TypeFileServer = args.typefileserver


        PortSftp=start_port +1
        PortFtps=start_port +2
        start_port +=2
        UrlFtps = str(ipaddress.ip_address(args.ipstart) + int(3 + (i * 16)))
        print("\tUrl Ftps: " + str(UrlFtps))

        UrlSftp = str(ipaddress.ip_address(args.ipstart) + int(4 + (i * 16)))
        print("\tUrl Sftp: " + str(UrlSftp))

        foldername = "pnf-sim-lw-" + str(i)
        completed = subprocess.run('mkdir ' + foldername, shell=True)
        print('\tCreating folder:', completed.stdout)
        completed = subprocess.run(
            'cp -r pnf-sim-lightweight/* ' +
            foldername,
            shell=True)
        print('\tCloning folder:', completed.stdout)

        composercmd = "./simulator.sh compose " + \
            str(ip_gw) + " " + \
            str(ip_subnet) + " " + \
            str(i) + " " + \
            str(args.urlves) + " " + \
            str(IpPnfSim) + " " + \
            str(IpFileServer) + " " + \
            str(TypeFileServer) + " " + \
            str(PortSftp) + " " + \
            str(PortFtps) + " " + \
            str(UrlFtps) + " " + \
            str(UrlSftp) + " " + \
            str(ftps_pasv_port_start) + " " + \
            str(ftps_pasv_port_end)

        completed = subprocess.run(
            'set -x; cd ' +
            foldername +
            '; ' +
            composercmd,
            shell=True)
        print('Cloning:', completed.stdout)

        ftps_pasv_port_start += ftps_pasv_port_num_of_ports + 1
        ftps_pasv_port_end += ftps_pasv_port_num_of_ports +1

    completed = subprocess.run('set -x; cd pnf-sim-lightweight; ./simulator.sh build ', shell=True)
    print("Build docker image: ", completed.stdout)

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
            "; ./simulator.sh stop " + str(i),
            shell=True)
        print('Stopping:', completed.stdout)


if args.trigger:
    print("Triggering VES sending:")

    for i in range(int(args.trigger)):
        foldername = "pnf-sim-lw-" + str(i)

        completed = subprocess.run(
            'cd ' +
            foldername +
            "; ./simulator.sh trigger-simulator",
            shell=True)
        print('Status:', completed.stdout)

if args.triggerstart and args.triggerend:
    print("Triggering VES sending by a range of simulators:")

    for i in range(int(args.triggerstart), int(args.triggerend)+1):
        foldername = "pnf-sim-lw-" + str(i)
        print("Instance being processed:" + str(i))

        completed = subprocess.run(
            'cd ' +
            foldername +
            "; ./simulator.sh trigger-simulator",
            shell=True)
        print('Status:', completed.stdout)
else:
    print("No instruction was defined")
    parser.print_usage()
    sys.exit()
