#!/usr/bin/env python3
import logging
from subprocess import run, CalledProcessError
import argparse
import ipaddress
from sys import exit
from os import chdir, getcwd, path, popen, kill
from shutil import copytree, rmtree
from json import loads, dumps
from yaml import load, SafeLoader
from glob import glob
from docker import from_env
from requests import get, codes, post
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
                        self._run_cmd(cmd, f"{self.sim_dirname_pattern}{i}")
                return action_wrap
            return action_decorator

    log_lvl = logging.INFO
    sim_config = 'config/config.yml'
    sim_msg_config = 'config/config.json'
    sim_port = 5000
    sim_base_url = 'http://{}:' + str(sim_port) + '/simulator'
    sim_start_url = sim_base_url + '/start'
    sim_status_url = sim_base_url + '/status'
    sim_container_name = 'pnf-simulator'
    rop_script_name = 'ROP_file_creator.sh'

    def __init__(self, args):
        self.args = args
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(self.log_lvl)
        self.sim_dirname_pattern = "pnf-sim-lw-"
        self.mvn_build_cmd = 'mvn clean package docker:build -Dcheckstyle.skip'
        self.docker_compose_status_cmd = 'docker-compose ps'
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

    def _get_sim_instance_data(self, instance_id):
        '''Helper method that returns specific instance data'''
        oldpwd = getcwd()
        chdir(f"{self.sim_dirname_pattern}{instance_id}")
        with open(self.sim_config) as cfg:
            yml = load(cfg, Loader=SafeLoader)
        chdir(oldpwd)
        return yml['ippnfsim']

    def _get_docker_containers(self):
        '''Returns a list containing 'name' attribute of running docker containers'''
        dc = from_env()
        containers = []
        for container in dc.containers.list():
            containers.append(container.attrs['Name'][1:])
        return containers

    def _get_iter_range(self):
        '''Helper routine to get the iteration range
        for the lifecycle commands'''
        if not self.args.count:
            return [self.existing_sim_instances]
        else:
            return [self.args.count]

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

    def status(self):
        for i in range(*self._get_iter_range()):
            self.logger.info(f'Getting {self.sim_dirname_pattern}{i} instance status:')
            if f"{self.sim_container_name}-{i}" in self._get_docker_containers():
                try:
                    sim_ip = self._get_sim_instance_data(i)
                    self.logger.info(f' PNF-Sim IP: {sim_ip}')
                    self._run_cmd(self.docker_compose_status_cmd, f"{self.sim_dirname_pattern}{i}")
                    sim_response = get('{}'.format(self.sim_status_url).format(sim_ip))
                    if sim_response.status_code == codes.ok:
                        self.logger.info(sim_response.text)
                    else:
                        self.logger.error(f'Simulator request returned http code {sim_response.status_code}')
                except KeyError:
                    self.logger.error(f'Unable to get sim instance IP from {self.sim_config}')
            else:
                self.logger.info(' Simulator containers are down')

    def stop(self):
        for i in range(*self._get_iter_range()):
            self.logger.info(f'Stopping {self.sim_dirname_pattern}{i} instance:')
            self.logger.info(f' PNF-Sim IP: {self._get_sim_instance_data(i)}')
            # attempt killing ROP script
            rop_pid = []
            for ps_line in iter(popen(f'ps --no-headers -C {self.rop_script_name} -o pid,cmd').readline, ''):
                # try getting ROP script pid
                try:
                    ps_line_arr = ps_line.split()
                    assert self.rop_script_name in ps_line_arr[2]
                    assert ps_line_arr[3] == str(i)
                    rop_pid = ps_line_arr[0]
                except AssertionError:
                    pass
                else:
                    # get rop script childs, kill ROP script and all childs
                    childs = popen(f'pgrep -P {rop_pid}').read().split()
                    for pid in [rop_pid] + childs:
                        kill(int(pid), 15)
                    self.logger.info(f' ROP_file_creator.sh {i} successfully killed')
            if not rop_pid:
                # no process found
                self.logger.warning(f' ROP_file_creator.sh {i} already not running')
            # try tearing down docker-compose application
            if f"{self.sim_container_name}-{i}" in self._get_docker_containers():
                self._run_cmd('docker-compose down', self.sim_dirname_pattern + str(i))
                self._run_cmd('docker-compose rm', self.sim_dirname_pattern + str(i))
            else:
                self.logger.warning(" Simulator containers are already down")

    def trigger(self):
        self.logger.info("Triggering VES sending:")
        for i in range(*self._get_iter_range()):
            sim_ip = self._get_sim_instance_data(i)
            self.logger.info(f'Triggering {self.sim_dirname_pattern}{i} instance:')
            self.logger.info(f' PNF-Sim IP: {sim_ip}')
            # setup req headers
            req_headers = {
                    "Content-Type": "application/json",
                    "X-ONAP-RequestID": "123",
                    "X-InvocationID": "456"
                }
            self.logger.debug(f' Request headers: {req_headers}')
            try:
                # get payload for the request
                with open(f'{self.sim_dirname_pattern}{i}/{self.sim_msg_config}') as data:
                    json_data = loads(data.read())
                    self.logger.debug(f' JSON payload for the simulator:\n{json_data}')
                    # make a http request to the simulator
                    sim_response = post('{}'.format(self.sim_start_url).format(sim_ip), headers=req_headers, json=json_data)
                    if sim_response.status_code == codes.ok:
                        self.logger.info(' Simulator response: ' + sim_response.text)
                    else:
                        self.logger.warning(' Simulator response ' + sim_response.text)
            except TypeError:
                self.logger.error(f' Could not load JSON data from {self.sim_dirname_pattern}{i}/{self.sim_msg_config}')

    @_MassPnfSim_Decorators.do_action('Triggering', './simulator.sh trigger-simulator')
    def trigger_custom(self):
        self.logger.info("Triggering VES sending by a range of simulators:")
