#!/usr/bin/env python3
import logging
import base64
from subprocess import run, CalledProcessError
import argparse
import ipaddress
from sys import exit
from os import chdir, getcwd, path, popen, kill, getuid, stat, mkdir, chmod
from shutil import copytree, rmtree, move
from json import loads, dumps
from yaml import load, SafeLoader, dump
from glob import glob
from time import strftime, tzname, daylight
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

def merge_dictionaries(origin, custom):
    '''Combine 2 dictionaries based on common keys.'''
    return {
            key: dict(
                origin.get(key, {}),
                **custom.get(key, {}))
            for key in origin.keys() | custom.keys()
        }

def validate_ip(ip):
    '''Helper function to validate input param is a vaild IP address'''
    try:
        ip_valid = ipaddress.ip_address(ip)
    except ValueError:
        raise argparse.ArgumentTypeError(f'{ip} is not a valid IP address')
    else:
        return ip_valid

def get_auth_token_base64(plain):
    '''Converts user:password to Base64.'''
    basic_auth_plain = plain
    basic_auth_bytes = basic_auth_plain.encode('ascii')
    basic_auth_base64_bytes = base64.b64encode(basic_auth_bytes)
    basic_auth_base64 = basic_auth_base64_bytes.decode('ascii')
    return basic_auth_base64

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
    parser_bootstrap.add_argument('--user', help='File server username', type=str, metavar='USERNAME', required=True)
    parser_bootstrap.add_argument('--password', help='File server password', type=str, metavar='PASSWORD', required=True)
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
    parser_trigger.add_argument('--user', help='VES auth username', type=str, metavar='USERNAME')
    parser_trigger.add_argument('--password', help='VES auth password', type=str, metavar='PASSWORD')
    # Stop-simulator command parser
    parser_stopsimulator = subparsers.add_parser('stop_simulator', help='Stop sending PNF registration messages')
    parser_stopsimulator.add_argument('--count', help='Instance count to stop', type=int, metavar='INT', default=0)
    # Trigger-custom command parser
    parser_triggerstart = subparsers.add_parser('trigger_custom', help='Trigger one single VES event from specific simulators')
    parser_triggerstart.add_argument('--triggerstart', help='First simulator id to trigger', type=int,
                                     metavar='INT', required=True)
    parser_triggerstart.add_argument('--triggerend', help='Last simulator id to trigger', type=int,
                                     metavar='INT', required=True)
    parser_triggerstart.add_argument('--user', help='VES auth username', type=str, metavar='USERNAME')
    parser_triggerstart.add_argument('--password', help='VES auth password', type=str, metavar='PASSWORD')
    parser_triggerstart.add_argument('--data', help='Custom data to override default values', type=dict, metavar='DATA')
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
        def validate_subcommand(method):
            def wrapper(self, args): # pylint: disable=W0613
                # Validate 'trigger_custom' subcommand options
                if self.args.subcommand == 'trigger_custom':
                    if (self.args.triggerend + 1) > self._enum_sim_instances():
                        self.logger.error('--triggerend value greater than existing instance count.')
                        exit(1)

                # Validate --count option for subcommands that support it
                if self.args.subcommand in ['start', 'stop', 'trigger', 'status', 'stop_simulator']:
                    if self.args.count > self._enum_sim_instances():
                        self.logger.error('--count value greater that existing instance count')
                        exit(1)
                    if not self._enum_sim_instances():
                        self.logger.error('No bootstrapped instance found')
                        exit(1)

                # Validate 'bootstrap' subcommand
                if (self.args.subcommand == 'bootstrap') and self._enum_sim_instances():
                    self.logger.error('Bootstrapped instances detected, not overwiriting, clean first')
                    exit(1)
                method(self, args)
            return wrapper

        @staticmethod
        def substitute_instance_args(method):
            def wrapper(self, args):
                self.args = args
                method(self, args)
            return wrapper

    log_lvl = logging.INFO
    sim_compose_template = 'docker-compose-template.yml'
    sim_vsftpd_template = 'config/vsftpd_ssl-TEMPLATE.conf'
    sim_vsftpd_config = 'config/vsftpd_ssl.conf'
    sim_sftp_script = 'fix-sftp-perms.sh'
    sim_sftp_script_template = 'fix-sftp-perms-template.sh'
    sim_config = 'config/config.yml'
    sim_msg_config = 'config/config.json'
    sim_port = 5000
    sim_base_url = 'http://{}:' + str(sim_port) + '/simulator'
    sim_start_url = sim_base_url + '/start'
    sim_status_url = sim_base_url + '/status'
    sim_stop_url = sim_base_url + '/stop'
    sim_container_name = 'pnf-simulator'
    rop_script_name = 'ROP_file_creator.sh'

    def __init__(self):
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(self.log_lvl)
        self.sim_dirname_pattern = "pnf-sim-lw-"
        self.mvn_build_cmd = 'mvn clean package docker:build -Dcheckstyle.skip'
        self.docker_compose_status_cmd = 'docker-compose ps'

    def _run_cmd(self, cmd, dir_context='.'):
        old_pwd = getcwd()
        try:
            chdir(dir_context)
            self.logger.debug(f'_run_cmd: Current direcotry: {getcwd()}')
            self.logger.debug(f'_run_cmd: Command string: {cmd}')
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
        if hasattr(self.args, 'count'):
            if not self.args.count:
                return [self._enum_sim_instances()]
            else:
                return [self.args.count]
        elif hasattr(self.args, 'triggerstart'):
            return [self.args.triggerstart, self.args.triggerend + 1]
        else:
            return [self._enum_sim_instances()]

    def _archive_logs(self, sim_dir):
        '''Helper function to archive simulator logs or create the log dir'''
        old_pwd = getcwd()
        try:
            chdir(sim_dir)
            if path.isdir('logs'):
                arch_dir = f"logs/archive_{strftime('%Y-%m-%d_%T')}"
                mkdir(arch_dir)
                self.logger.debug(f'Created {arch_dir}')
                # Collect file list to move
                self.logger.debug('Archiving log files')
                for fpattern in ['*.log', '*.xml']:
                    for f in glob('logs/' + fpattern):
                        # Move files from list to arch dir
                        move(f, arch_dir)
                        self.logger.debug(f'Moving {f} to {arch_dir}')
            else:
                mkdir('logs')
                self.logger.debug("Logs dir didn't exist, created")
            chdir(old_pwd)
        except FileNotFoundError:
            self.logger.error(f"Directory {sim_dir} not found")

    def _generate_pnf_sim_config(self, i, port_sftp, port_ftps, pnf_sim_ip):
        '''Writes a yaml formatted configuration file for Java simulator app'''
        yml = {}
        yml['urlves'] = self.args.urlves
        yml['urlsftp'] = f'sftp://{self.args.user}:{self.args.password}@{self.args.ipfileserver}:{port_sftp}'
        yml['urlftps'] = f'ftps://{self.args.user}:{self.args.password}@{self.args.ipfileserver}:{port_ftps}'
        yml['ippnfsim'] = pnf_sim_ip
        yml['typefileserver'] = self.args.typefileserver
        self.logger.debug(f'Generated simulator config:\n{dump(yml)}')
        with open(f'{self.sim_dirname_pattern}{i}/{self.sim_config}', 'w') as fout:
            fout.write(dump(yml))

    def _generate_config_file(self, source, dest, **kwargs):
        '''Helper private method to generate a file based on a template'''
        old_pwd = getcwd()
        chdir(self.sim_dirname_pattern + str(kwargs['I']))
        # Read the template file
        with open(source, 'r') as f:
            template = f.read()
        # Replace all occurences of env like variable with it's
        # relevant value from a corresponding key form kwargs
        for (k,v) in kwargs.items():
            template = template.replace('${' + k + '}', str(v))
        with open(dest, 'w') as f:
            f.write(template)
        chdir(old_pwd)

    @_MassPnfSim_Decorators.substitute_instance_args
    @_MassPnfSim_Decorators.validate_subcommand
    def bootstrap(self, args): # pylint: disable=W0613
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
            self.logger.info(f"\tCreating instance #{i} configuration ")
            self._generate_pnf_sim_config(i, PortSftp, PortFtps, ip['PnfSim'])
            # generate docker-compose for the simulator instance
            self._generate_config_file(self.sim_compose_template, 'docker-compose.yml',
                                       IPGW = ip['gw'], IPSUBNET = ip['subnet'],
                                       I = i, IPPNFSIM = ip['PnfSim'],
                                       PORTSFTP = str(PortSftp),
                                       PORTFTPS = str(PortFtps),
                                       IPFTPS = ip['ftps'], IPSFTP = ip['sftp'],
                                       FTPS_PASV_MIN = str(ftps_pasv_port_start),
                                       FTPS_PASV_MAX = str(ftps_pasv_port_end),
                                       TIMEZONE = tzname[daylight],
                                       FILESERV_USER = self.args.user,
                                       FILESERV_PASS = self.args.password)
            # generate vsftpd config file for the simulator instance
            self._generate_config_file(self.sim_vsftpd_template, self.sim_vsftpd_config,
                                       I = i,
                                       FTPS_PASV_MIN = str(ftps_pasv_port_start),
                                       FTPS_PASV_MAX = str(ftps_pasv_port_end),
                                       IPFILESERVER = str(self.args.ipfileserver))
            # generate sftp permission fix script
            self._generate_config_file(self.sim_sftp_script_template, self.sim_sftp_script,
                                       I = i, FILESERV_USER = self.args.user)
            chmod(f'{self.sim_dirname_pattern}{i}/{self.sim_sftp_script}', 0o755)

            ftps_pasv_port_start += ftps_pasv_port_num_of_ports + 1
            ftps_pasv_port_end += ftps_pasv_port_num_of_ports + 1

            # ugly hack to chown vsftpd config file to root
            if getuid():
                self._run_cmd(f'sudo chown root {self.sim_vsftpd_config}', f'{self.sim_dirname_pattern}{i}')
                self.logger.debug(f"vsftpd config file owner UID: {stat(self.sim_dirname_pattern + str(i) + '/' + self.sim_vsftpd_config).st_uid}")

            self.logger.info(f'Done setting up instance #{i}')

    @_MassPnfSim_Decorators.substitute_instance_args
    def build(self, args): # pylint: disable=W0613
        self.logger.info("Building simulator image")
        if path.isfile('pnf-sim-lightweight/pom.xml'):
            self._run_cmd(self.mvn_build_cmd, 'pnf-sim-lightweight')
        else:
            self.logger.error('POM file was not found, Maven cannot run')
            exit(1)

    @_MassPnfSim_Decorators.substitute_instance_args
    def clean(self, args): # pylint: disable=W0613
        self.logger.info('Cleaning simulators workdirs')
        for sim_id in range(self._enum_sim_instances()):
            rmtree(f"{self.sim_dirname_pattern}{sim_id}")

    @_MassPnfSim_Decorators.substitute_instance_args
    @_MassPnfSim_Decorators.validate_subcommand
    def start(self, args): # pylint: disable=W0613
        for i in range(*self._get_iter_range()):
            # Start measurements file generator if not running
            rop_running = False
            for ps_line in iter(popen(f'ps --no-headers -C {self.rop_script_name} -o pid,cmd').readline, ''):
                # try getting ROP script pid
                try:
                    ps_line_arr = ps_line.split()
                    assert self.rop_script_name in ps_line_arr[2]
                    assert ps_line_arr[3] == str(i)
                except AssertionError:
                    pass
                else:
                    self.logger.warning(f'3GPP measurements file generator for instance {i} is already running')
                    rop_running = True
            if not rop_running:
                self._run_cmd(f'./ROP_file_creator.sh {i} &', f"{self.sim_dirname_pattern}{i}")
                self.logger.info(f'ROP_file_creator.sh {i} successfully started')
            # If container is not running
            if f"{self.sim_container_name}-{i}" not in self._get_docker_containers():
                self.logger.info(f'Starting {self.sim_dirname_pattern}{i} instance:')
                self.logger.info(f' PNF-Sim IP: {self._get_sim_instance_data(i)}')
                #Move logs to archive
                self._archive_logs(self.sim_dirname_pattern + str(i))
                self.logger.info(' Starting simulator containers using netconf model specified in config/netconf.env')
                self._run_cmd('docker-compose up -d', self.sim_dirname_pattern + str(i))
            else:
                self.logger.warning(f'Instance {self.sim_dirname_pattern}{i} containers are already up')

    @_MassPnfSim_Decorators.substitute_instance_args
    @_MassPnfSim_Decorators.validate_subcommand
    def status(self, args): # pylint: disable=W0613
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

    @_MassPnfSim_Decorators.substitute_instance_args
    @_MassPnfSim_Decorators.validate_subcommand
    def stop(self, args): # pylint: disable=W0613
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

    @_MassPnfSim_Decorators.substitute_instance_args
    @_MassPnfSim_Decorators.validate_subcommand
    def trigger(self, args): # pylint: disable=W0613
        self.logger.info("Triggering VES sending:")

        for i in range(*self._get_iter_range()):

            sim_ip = self._get_sim_instance_data(i)
            self.logger.info(f'Triggering {self.sim_dirname_pattern}{i} instance:')
            self.logger.info(f' PNF-Sim IP: {sim_ip}')

            # create a Basic auth token
            plaintext_auth = f"{args.user}:{args.password}"
            basic_auth_base64 = get_auth_token_base64(plaintext_auth)
            basic_auth_token = f"Basic {basic_auth_base64}"
            self.logger.info((basic_auth_base64))

            # setup req headers
            req_headers = {
                    "Content-Type": "application/json",
                    "X-ONAP-RequestID": "123",
                    "X-InvocationID": "456",
                    "Authorization": basic_auth_token
                }
            self.logger.debug(f' Request headers: {req_headers}')

            try:

                # get payload for the request
                with open(f'{self.sim_dirname_pattern}{i}/{self.sim_msg_config}') as data:

                    json_data = loads(data.read())
                    try:
                        json_data = merge_dictionaries(json_data, args.data)
                    except AttributeError:
                        self.logger.debug('The request will be sent without customization.')

                    self.logger.debug(f' JSON payload for the simulator:\n{json_data}')

                    # make a http request to the simulator
                    sim_response = post('{}'.format(self.sim_start_url).format(sim_ip), headers=req_headers, json=json_data)

                    if sim_response.status_code == codes.ok:
                        self.logger.info(' Simulator response: ' + sim_response.text)
                    else:
                        self.logger.warning(' Simulator response ' + sim_response.text)

            except TypeError:
                self.logger.error(f' Could not load JSON data from {self.sim_dirname_pattern}{i}/{self.sim_msg_config}')

    # Make the 'trigger_custom' an alias to the 'trigger' method
    trigger_custom = trigger

    @_MassPnfSim_Decorators.substitute_instance_args
    @_MassPnfSim_Decorators.validate_subcommand
    def stop_simulator(self, args): # pylint: disable=W0613
        self.logger.info("Stopping sending PNF registration messages:")
        for i in range(*self._get_iter_range()):
            sim_ip = self._get_sim_instance_data(i)
            self.logger.info(f'Stopping {self.sim_dirname_pattern}{i} instance:')
            self.logger.info(f' PNF-Sim IP: {sim_ip}')
            sim_response = post('{}'.format(self.sim_stop_url).format(sim_ip))
            if sim_response.status_code == codes.ok:
                self.logger.info(' Simulator response: ' + sim_response.text)
            else:
                self.logger.warning(' Simulator response ' + sim_response.text)
