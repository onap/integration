#!/usr/bin/env python3
import argparse
import sys
import logging
import ipaddress
from MassPnfSim import MassPnfSim
from requests import get
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

def get_parser():
    '''Process input arguments'''

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
    # Trigger-custom command parser
    parser_triggerstart = subparsers.add_parser('trigger-custom', help='Trigger one single VES event from specific simulators')
    parser_triggerstart.add_argument('--triggerstart', help='First simulator id to trigger', type=int,
                                     metavar='INT', required=True)
    parser_triggerstart.add_argument('--triggerend', help='Last simulator id to trigger', type=int,
                                     metavar='INT', required=True)
    # Status command parser
    parser_status = subparsers.add_parser('status', help='Status')
    parser_status.add_argument('--count', help='Instance count to show status for', type=int, metavar='INT', default=1)
    # Clean command parser
    subparsers.add_parser('clean', help='Clean work-dirs')
    # General options parser
    parser.add_argument('--verbose', help='Verbosity level', choices=['info', 'debug'],
                        type=str, default='debug')
    return parser

if __name__ == '__main__':
    parser = get_parser()
    args = parser.parse_args()
    log_lvl = getattr(logging, args.verbose.upper())

    logger = logging.getLogger(__name__)
    logger.setLevel(log_lvl)
    MassPnfSim.log_lvl = log_lvl

    if args.subcommand is not None:
        sim = MassPnfSim(args)
        if args.subcommand == 'bootstrap' :
            sim.bootstrap()
        if args.subcommand == 'clean':
            sim.clean()
        if args.subcommand == 'start':
            sim.start()
        if args.subcommand == 'status':
            sim.status()
        if args.subcommand == 'stop':
            sim.stop()
        if args.subcommand == 'trigger':
            sim.trigger()
        if args.subcommand == 'trigger-custom':
            sim.trigger_custom()
    else:
        parser.print_usage()
