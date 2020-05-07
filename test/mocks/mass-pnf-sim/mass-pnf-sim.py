#!/usr/bin/env python3
import argparse
import sys
import subprocess
import ipaddress
import time
import logging
from requests import get
from json import dumps
from requests.exceptions import MissingSchema, InvalidSchema, InvalidURL, ConnectionError, ConnectTimeout

def validate_url(url):
    '''Helper function to perform --urlves input param validation'''
    logger = logging.getLogger("urllib3")
    logger.setLevel(logging.WARNING)
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

if sys.stdout.isatty():
    logging.basicConfig(level=logging.INFO, format='\033[92m[%(levelname)s]\033[0m %(message)s')
else:
    logging.basicConfig(level=logging.INFO, format='[%(levelname)s] %(message)s')

parser = argparse.ArgumentParser()
parser.add_argument('--bootstrap', help='Bootstrap the system', type=int, metavar='COUNT')
parser.add_argument('--trigger', help='Trigger one single VES event from each simulator', type=int,
                    metavar='COUNT')
parser.add_argument('--triggerstart', help='Trigger only a subset of the simulators (note --triggerend)', type=int,
                    metavar='COUNT_START')
parser.add_argument('--triggerend', help='Last instance to trigger', type=int, metavar='COUNT_END')
parser.add_argument('--urlves', help='URL of the VES collector', type=validate_url, metavar='URL')
parser.add_argument('--ipfileserver', help='Visible IP of the file server (SFTP/FTPS) to be included in the VES event',
                    type=validate_ip, metavar='IP')
parser.add_argument('--typefileserver', help='Type of the file server (SFTP/FTPS) to be included in the VES event',
                    type=str, choices=['sftp', 'ftps'])
parser.add_argument('--ipstart', help='IP address range beginning', type=validate_ip, metavar='IP')
parser.add_argument('--clean', action='store_true', help='Clean work-dirs')
parser.add_argument('--start', help='Start instances', type=int, metavar='COUNT')
parser.add_argument('--status', help='Status', type=int, metavar='COUNT')
parser.add_argument('--stop', help='Stop instances', type=int, metavar='COUNT')
parser.add_argument('--verbose', help='Verbosity level', choices=['info', 'debug'],
                    type=str, default='debug')

args = parser.parse_args()

logger = logging.getLogger(__name__)
logger.setLevel(getattr(logging, args.verbose.upper()))

if args.bootstrap and args.ipstart and args.urlves:
    logger.info("Bootstrapping PNF instances")

    start_port = 2000
    ftps_pasv_port_start = 8000
    ftps_pasv_port_num_of_ports = 10

    ftps_pasv_port_end = ftps_pasv_port_start + ftps_pasv_port_num_of_ports

    for i in range(args.bootstrap):
        logger.info(f"PNF simulator instance: {i}")

        # The IP ranges are in distance of 16 compared to each other.
        # This is matching the /28 subnet mask used in the dockerfile inside.
        instance_ip_offset = i * 16
        ip_properties = [
                  'subnet',
                  'gw',
                  'PnfSim',
                  'ftps',
                  'sftp'
                ]

        ip_offset = 0
        ip = {}
        for prop in ip_properties:
            ip.update({prop: str(args.ipstart + ip_offset + instance_ip_offset)})
            ip_offset += 1

        logger.debug(f'Instance #{i} properties:\n {dumps(ip, indent=4)}')

        PortSftp = start_port + 1
        PortFtps = start_port + 2
        start_port += 2

        foldername = f"pnf-sim-lw-{i}"
        completed = subprocess.run('mkdir ' + foldername, shell=True)
        logger.info(f'\tCreating folder: {completed.stdout}')
        completed = subprocess.run(
            'cp -r pnf-sim-lightweight/* ' +
            foldername,
            shell=True)
        logger.info(f'\tCloning folder: {completed.stdout}')

        composercmd = " ".join([
                "./simulator.sh compose",
                ip['gw'],
                ip['subnet'],
                str(i),
                args.urlves,
                ip['PnfSim'],
                str(args.ipfileserver),
                args.typefileserver,
                str(PortSftp),
                str(PortFtps),
                ip['ftps'],
                ip['sftp'],
                str(ftps_pasv_port_start),
                str(ftps_pasv_port_end)
            ])
        logger.debug(f"Script cmdline: {composercmd}")

        completed = subprocess.run(
            'set -x; cd ' +
            foldername +
            '; ' +
            composercmd,
            shell=True)
        logger.info(f'Cloning: {completed.stdout}')

        ftps_pasv_port_start += ftps_pasv_port_num_of_ports + 1
        ftps_pasv_port_end += ftps_pasv_port_num_of_ports + 1

        logger.info(f'Done setting up instance #{i}')

    completed = subprocess.run('set -x; cd pnf-sim-lightweight; ./simulator.sh build ', shell=True)
    logger.info(f"Build docker image: {completed.stdout}")

    sys.exit()

if args.clean:
    completed = subprocess.run('rm -rf ./pnf-sim-lw-*', shell=True)
    logger.info(f'Deleting: {completed.stdout}')
    sys.exit()

if args.start:

    for i in range(args.start):
        foldername = f"pnf-sim-lw-{i}"

        completed = subprocess.run(
            'set -x ; cd ' +
            foldername +
            "; bash -x ./simulator.sh start",
            shell=True)
        logger.info(f'Starting: {completed.stdout}')

        time.sleep(5)

if args.status:

    for i in range(args.status):
        foldername = f"pnf-sim-lw-{i}"

        completed = subprocess.run(
            'cd ' +
            foldername +
            "; ./simulator.sh status",
            shell=True)
        logger.info(f'Status: {completed.stdout}')

if args.stop:
    for i in range(args.stop):
        foldername = f"pnf-sim-lw-{i}"

        completed = subprocess.run(
            'cd ' +
            foldername +
            f"; ./simulator.sh stop {i}",
            shell=True)
        logger.info(f'Stopping: {completed.stdout}')


if args.trigger:
    logger.info("Triggering VES sending:")

    for i in range(args.trigger):
        foldername = f"pnf-sim-lw-{i}"

        completed = subprocess.run(
            'cd ' +
            foldername +
            "; ./simulator.sh trigger-simulator",
            shell=True)
        logger.info(f'Status: {completed.stdout}')

if args.triggerstart and args.triggerend:
    logger.info("Triggering VES sending by a range of simulators:")

    for i in range(args.triggerstart, args.triggerend+1):
        foldername = f"pnf-sim-lw-{i}"
        logger.info(f"Instance being processed: {i}")

        completed = subprocess.run(
            'cd ' +
            foldername +
            "; ./simulator.sh trigger-simulator",
            shell=True)
        logger.info(f'Status: {completed.stdout}')
else:
    logger.warning("No instruction was defined")
    parser.print_usage()
    sys.exit()
