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
subparsers = parser.add_subparsers(title='Subcommands', dest='subcommand')
# Bootstrap command parser
parser_bootstrap = subparsers.add_parser('bootstrap', help='Bootstrap the system')
parser_bootstrap.add_argument('--count', help='Instance count to bootstrap', type=int, metavar='INT', default=1)
parser_bootstrap.add_argument('--urlves', help='URL of the VES collector', type=validate_url, metavar='URL', required=True)
parser_bootstrap.add_argument('--ipfileserver', help='Visible IP of the file server (SFTP/FTPS) to be included in the VES event',
                              type=validate_ip, metavar='IP', required=True)
parser_bootstrap.add_argument('--typefileserver', help='Type of the file server (SFTP/FTPS) to be included in the VES event',
                              type=str, choices=['sftp', 'ftps'], required=True)
parser_bootstrap.add_argument('--ipstart', help='IP address range beginning', type=validate_ip, metavar='IP', required=True)
# Start command parser
parser_start = subparsers.add_parser('start', help='Start instances')
parser_start.add_argument('--count', help='Instance count to start', type=int, metavar='INT', default=1)
# Stop command parser
parser_stop = subparsers.add_parser('stop', help='Stop instances')
parser_stop.add_argument('--count', help='Instance count to stop', type=int, metavar='INT', default=1)
# Trigger command parser
parser_trigger = subparsers.add_parser('trigger', help='Trigger one single VES event from each simulator')
parser_trigger.add_argument('--count', help='Instance count to trigger', type=int, metavar='INT', default=1)
# Trigger-start command parser
parser_triggerstart = subparsers.add_parser('trigger-custom', help='Trigger one single VES event from specific simulators')
parser_triggerstart.add_argument('--triggerstart', help='First simulator id to trigger', type=int,
                                 metavar='INT', required=True)
parser_triggerstart.add_argument('--triggerend', help='Last simulator id to trigger', type=int,
                                 metavar='INT', required=True)
# Status command parser
parser_status = subparsers.add_parser('status', help='Status')
parser_status.add_argument('--count', help='Instance count to show status for', type=int, metavar='INT', default=1)
# Clean command parser
parser_clean = subparsers.add_parser('clean', help='Clean work-dirs')
# General options parser
parser.add_argument('--verbose', help='Verbosity level', choices=['info', 'debug'],
                    type=str, default='debug')

args = parser.parse_args()

logger = logging.getLogger(__name__)
logger.setLevel(getattr(logging, args.verbose.upper()))

if args.subcommand is None:
    parser.print_usage()
    sys.exit(0)

if args.subcommand == 'bootstrap' :
    logger.info("Bootstrapping PNF instances")

    start_port = 2000
    ftps_pasv_port_start = 8000
    ftps_pasv_port_num_of_ports = 10

    ftps_pasv_port_end = ftps_pasv_port_start + ftps_pasv_port_num_of_ports

    for i in range(args.count):
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

if args.subcommand == 'clean':
    completed = subprocess.run('rm -rf ./pnf-sim-lw-*', shell=True)
    logger.info(f'Deleting: {completed.stdout}')

if args.subcommand == 'start':

    for i in range(args.count):
        foldername = f"pnf-sim-lw-{i}"

        completed = subprocess.run(
            'set -x ; cd ' +
            foldername +
            "; bash -x ./simulator.sh start",
            shell=True)
        logger.info(f'Starting: {completed.stdout}')
        time.sleep(5)

if args.subcommand == 'status':

    for i in range(args.count):
        foldername = f"pnf-sim-lw-{i}"

        completed = subprocess.run(
            'cd ' +
            foldername +
            "; ./simulator.sh status",
            shell=True)
        logger.info(f'Status: {completed.stdout}')

if args.subcommand == 'stop':
    for i in range(args.count):
        foldername = f"pnf-sim-lw-{i}"

        completed = subprocess.run(
            'cd ' +
            foldername +
            f"; ./simulator.sh stop {i}",
            shell=True)
        logger.info(f'Stopping: {completed.stdout}')


if args.subcommand == 'trigger':
    logger.info("Triggering VES sending:")

    for i in range(args.count):
        foldername = f"pnf-sim-lw-{i}"

        completed = subprocess.run(
            'cd ' +
            foldername +
            "; ./simulator.sh trigger-simulator",
            shell=True)
        logger.info(f'Status: {completed.stdout}')

if args.subcommand == 'trigger-custom':
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
