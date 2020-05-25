#!/usr/bin/env python3
import logging
from subprocess import run, CalledProcessError
import argparse
import ipaddress
from sys import exit
from os import chdir, getcwd, path
from shutil import copytree, rmtree
from json import dumps
from glob import glob
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

def get_parser():
    '''Process input arguments'''

    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(title='Subcommands', dest='subcommand')
    # Build command parser
    subparsers.add_parser('build', help='Build simulator image')
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
    parser_start.add_argument('--count', help='Instance count to start', type=int, metavar='INT', default=0)
    # Stop command parser
    parser_stop = subparsers.add_parser('stop', help='Stop instances')
    parser_stop.add_argument('--count', help='Instance count to stop', type=int, metavar='INT', default=0)
    # Trigger command parser
    parser_trigger = subparsers.add_parser('trigger', help='Trigger one single VES event from each simulator')
    parser_trigger.add_argument('--count', help='Instance count to trigger', type=int, metavar='INT', default=0)
    # Trigger-custom command parser
    parser_triggerstart = subparsers.add_parser('trigger_custom', help='Trigger one single VES event from specific simulators')
    parser_triggerstart.add_argument('--triggerstart', help='First simulator id to trigger', type=int,
                                     metavar='INT', required=True)
    parser_triggerstart.add_argument('--triggerend', help='Last simulator id to trigger', type=int,
                                     metavar='INT', required=True)
    # Status command parser
    parser_status = subparsers.add_parser('status', help='Status')
    parser_status.add_argument('--count', help='Instance count to show status for', type=int, metavar='INT', default=0)
    # Clean command parser
    subparsers.add_parser('clean', help='Clean work-dirs')
    # General options parser
    parser.add_argument('--verbose', help='Verbosity level', choices=['info', 'debug'],
                        type=str, default='info')
    return parser

class MassPnfSim:

    # MassPnfSim class actions decorator
    class _MassPnfSim_Decorators:

        @staticmethod
        def do_action(action_string, cmd):
            def action_decorator(method):
                def action_wrap(self):
                    cmd_local = cmd
                    # Append instance # if action is 'stop'
                    if method.__name__ == 'stop':
                        cmd_local += " {}"
                    # Alter looping range if action is 'tigger_custom'
                    if method.__name__ == 'trigger_custom':
                        iter_range = [self.args.triggerstart, self.args.triggerend+1]
                    else:
                        if not self.args.count:
                            # If no instance count set explicitly via --count
                            # option
                            iter_range = [self.existing_sim_instances]
                        else:
                            iter_range = [self.args.count]
                    method(self)
                    for i in range(*iter_range):
                        self.logger.info(f'{action_string} {self.sim_dirname_pattern}{i} instance:')
                        self._run_cmd(cmd_local.format(i), f"{self.sim_dirname_pattern}{i}")
                return action_wrap
            return action_decorator

    log_lvl = logging.INFO

    def __init__(self, args):
        self.args = args
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(self.log_lvl)
        self.sim_dirname_pattern = "pnf-sim-lw-"
        self.mvn_build_cmd = 'mvn clean package docker:build -Dcheckstyle.skip'
        self.existing_sim_instances = self._enum_sim_instances()

        # Validate 'trigger_custom' subcommand options
        if self.args.subcommand == 'trigger_custom':
            if (self.args.triggerend + 1) > self.existing_sim_instances:
                self.logger.error('--triggerend value greater than existing instance count.')
                exit(1)

        # Validate --count option for subcommands that support it
        if self.args.subcommand in ['start', 'stop', 'trigger', 'status']:
            if self.args.count > self.existing_sim_instances:
                self.logger.error('--count value greater that existing instance count')
                exit(1)
            if not self.existing_sim_instances:
                self.logger.error('No bootstrapped instance found')
                exit(1)

        # Validate 'bootstrap' subcommand
        if (self.args.subcommand == 'bootstrap') and self.existing_sim_instances:
            self.logger.error('Bootstrapped instances detected, not overwiriting, clean first')
            exit(1)

    def _run_cmd(self, cmd, dir_context='.'):
        if self.args.verbose == 'debug':
            cmd='bash -x ' + cmd
        old_pwd = getcwd()
        try:
            chdir(dir_context)
            run(cmd, check=True, shell=True)
            chdir(old_pwd)
        except FileNotFoundError:
            self.logger.error(f"Directory {dir_context} not found")
        except CalledProcessError as e:
            exit(e.returncode)

    def _enum_sim_instances(self):
        '''Helper method that returns bootstraped simulator instances count'''
        return len(glob(f"{self.sim_dirname_pattern}[0-9]*"))

    def bootstrap(self):
        self.logger.info("Bootstrapping PNF instances")

        start_port = 2000
        ftps_pasv_port_start = 8000
        ftps_pasv_port_num_of_ports = 10

        ftps_pasv_port_end = ftps_pasv_port_start + ftps_pasv_port_num_of_ports

        for i in range(self.args.count):
            self.logger.info(f"PNF simulator instance: {i}")

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
                ip.update({prop: str(self.args.ipstart + ip_offset + instance_ip_offset)})
                ip_offset += 1

            self.logger.debug(f'Instance #{i} properties:\n {dumps(ip, indent=4)}')

            PortSftp = start_port + 1
            PortFtps = start_port + 2
            start_port += 2

            self.logger.info(f'\tCreating {self.sim_dirname_pattern}{i}')
            copytree('pnf-sim-lightweight', f'{self.sim_dirname_pattern}{i}')

            composercmd = " ".join([
                    "./simulator.sh compose",
                    ip['gw'],
                    ip['subnet'],
                    str(i),
                    self.args.urlves,
                    ip['PnfSim'],
                    str(self.args.ipfileserver),
                    self.args.typefileserver,
                    str(PortSftp),
                    str(PortFtps),
                    ip['ftps'],
                    ip['sftp'],
                    str(ftps_pasv_port_start),
                    str(ftps_pasv_port_end)
                ])
            self.logger.debug(f"Script cmdline: {composercmd}")
            self.logger.info(f"\tCreating instance #{i} configuration ")
            self._run_cmd(composercmd, f"{self.sim_dirname_pattern}{i}")

            ftps_pasv_port_start += ftps_pasv_port_num_of_ports + 1
            ftps_pasv_port_end += ftps_pasv_port_num_of_ports + 1

            self.logger.info(f'Done setting up instance #{i}')

    def build(self):
        self.logger.info("Building simulator image")
        if path.isfile('pnf-sim-lightweight/pom.xml'):
            self._run_cmd(self.mvn_build_cmd, 'pnf-sim-lightweight')
        else:
            self.logger.error('POM file was not found, Maven cannot run')
            exit(1)

    def clean(self):
        self.logger.info('Cleaning simulators workdirs')
        for sim_id in range(self.existing_sim_instances):
            rmtree(f"{self.sim_dirname_pattern}{sim_id}")

    @_MassPnfSim_Decorators.do_action('Starting', './simulator.sh start')
    def start(self):
        pass

    @_MassPnfSim_Decorators.do_action('Getting', './simulator.sh status')
    def status(self):
        pass

    @_MassPnfSim_Decorators.do_action('Stopping', './simulator.sh stop')
    def stop(self):
        pass

    @_MassPnfSim_Decorators.do_action('Triggering', './simulator.sh trigger-simulator')
    def trigger(self):
        self.logger.info("Triggering VES sending:")

    @_MassPnfSim_Decorators.do_action('Triggering', './simulator.sh trigger-simulator')
    def trigger_custom(self):
        self.logger.info("Triggering VES sending by a range of simulators:")
