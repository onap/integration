#!/usr/bin/env python3
import logging
import subprocess
import time
from json import dumps

class MassPnfSim():

    log_lvl = logging.INFO

    def __init__(self, args):
        self.args = args
        self.logger = logging.getLogger(__name__)
        self.logger.setLevel(self.log_lvl)

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

            foldername = f"pnf-sim-lw-{i}"
            completed = subprocess.run('mkdir ' + foldername, shell=True)
            self.logger.info(f'\tCreating folder: {completed.stdout}')
            completed = subprocess.run(
                'cp -r pnf-sim-lightweight/* ' +
                foldername,
                shell=True)
            self.logger.info(f'\tCloning folder: {completed.stdout}')

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

            completed = subprocess.run(
                'set -x; cd ' +
                foldername +
                '; ' +
                composercmd,
                shell=True)
            self.logger.info(f'Cloning: {completed.stdout}')

            ftps_pasv_port_start += ftps_pasv_port_num_of_ports + 1
            ftps_pasv_port_end += ftps_pasv_port_num_of_ports + 1

            self.logger.info(f'Done setting up instance #{i}')

        completed = subprocess.run('set -x; cd pnf-sim-lightweight; ./simulator.sh build ', shell=True)
        self.logger.info(f"Build docker image: {completed.stdout}")

    def clean(self):
        completed = subprocess.run('rm -rf ./pnf-sim-lw-*', shell=True)
        self.logger.info(f'Deleting: {completed.stdout}')

    def start(self):
        for i in range(self.args.count):
            foldername = f"pnf-sim-lw-{i}"

            completed = subprocess.run(
                'set -x ; cd ' +
                foldername +
                "; bash -x ./simulator.sh start",
                shell=True)
            self.logger.info(f'Starting: {completed.stdout}')
            time.sleep(5)

    def status(self):
        for i in range(self.args.count):
            foldername = f"pnf-sim-lw-{i}"

            completed = subprocess.run(
                'cd ' +
                foldername +
                "; ./simulator.sh status",
                shell=True)
            self.logger.info(f'Status: {completed.stdout}')

    def stop(self):
        for i in range(self.args.count):
            foldername = f"pnf-sim-lw-{i}"

            completed = subprocess.run(
                'cd ' +
                foldername +
                f"; ./simulator.sh stop {i}",
                shell=True)
            self.logger.info(f'Stopping: {completed.stdout}')

    def trigger(self):
        self.logger.info("Triggering VES sending:")

        for i in range(self.args.count):
            foldername = f"pnf-sim-lw-{i}"

            completed = subprocess.run(
                'cd ' +
                foldername +
                "; ./simulator.sh trigger-simulator",
                shell=True)
            self.logger.info(f'Status: {completed.stdout}')

    def trigger_custom(self):
        self.logger.info("Triggering VES sending by a range of simulators:")

        for i in range(self.args.triggerstart, self.args.triggerend+1):
            foldername = f"pnf-sim-lw-{i}"
            self.logger.info(f"Instance being processed: {i}")

            completed = subprocess.run(
                'cd ' +
                foldername +
                "; ./simulator.sh trigger-simulator",
                shell=True)
            self.logger.info(f'Status: {completed.stdout}')
