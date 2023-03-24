#!/usr/bin/env python3

# ============LICENSE_START=======================================================
#  Copyright (C) 2022 Orange, Ltd.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================
#
# Launch basic_* tests in parallel and report results
# the possible basic tests are:
# - basic_onboarding
# - basic_vm
# - basic_network
# - basic_cnf
# - ...

# Dependencies:
#     See requirements.txt
#     The dashboard is based on bulma framework
#
# Environment:
#
# Example usage:
#       python launcher.py
#               -t <test>
#               -s <nb simultaneous occurences>
#               -d <duration>
#               -r <reporting path>
#
# the summary html page will be generated where the script is launched
"""
Check ONAP certificates
"""
import argparse
import logging
import os
import sys
import random
import string
import time
import docker  # pylint: disable=import-error

import onaptests_bench.reporting as Reporting

HOMEPATH = os.environ.get("HOME", "/home/ubuntu")

sys.path.append(f"{HOMEPATH}/onaptests_bench/src/onaptests_bench")

# Logger
LOG_LEVEL = 'INFO'
logging.basicConfig()
LOGGER = logging.getLogger("onaptests_bench")
LOGGER.setLevel(LOG_LEVEL)
TEST_LIST = ['basic_onboard', 'basic_vm', 'basic_vm_macro',
             'basic_network', 'basic_cnf']
DEFAULT_TEST = TEST_LIST[0]
DEFAULT_SIMU_TESTS = 5
DEFAULT_TEST_DURATION = 180 # duration in minutes
RESULT_PATH = "/tmp"
ONAPTEST_BENCH_WAIT_TIMER = 40
ONAPTESTS_PATH = "/usr/lib/python3.8/site-packages/onaptests"
ONAPTESTS_SETTINGS = f"{ONAPTESTS_PATH}/configuration/settings.py"
ONAPTESTS_SERVICE_DIR = f"{ONAPTESTS_PATH}/templates/vnf-services"

CLUSTER_IP = "127.0.0.1"

# Get arguments
PARSER = argparse.ArgumentParser()
PARSER.add_argument(
    '-t',
    '--test',
    choices=TEST_LIST,
    help=('Select your test (basic_onboard, basic_vm, basic_network, basic_cnf).' +
          'If not set, basic_onboarding is considered'),
    default=DEFAULT_TEST)
PARSER.add_argument(
    '-s',
    '--simu',
    type=int,
    help='Number of simultaneous tests',
    default=DEFAULT_SIMU_TESTS)
PARSER.add_argument(
    '-d',
    '--duration',
    type=int,
    help='Test duration (in minutes)',
    default=DEFAULT_TEST_DURATION)
PARSER.add_argument(
    '-r',
    '--reporting',
    help='Result directory',
    default=RESULT_PATH)
PARSER.add_argument(
    '-i',
    '--ip',
    help='Cluster IP',
    default=CLUSTER_IP)

ARGS = PARSER.parse_args()

def prepare_test_config():
    """Check the test execution.
       We supposed that basic_vm tests are already available in /tmp/xtesting
       If not the tests cannot be executed."""
    LOGGER.info("Prepare the test, verify that the test can be run")

def get_container_name():
    """Set Container name."""
    result_str = ''.join(random.choice(string.ascii_letters) for i in range(8))
    container_name = ARGS.test + "_" + result_str
    return container_name

def clean_test_device(docker_client, test):
    """Clean test resources."""
    container_list = docker_client.containers.list(
        all=True,
        filters={'label':'test='+test})
    LOGGER.info("Containers cleanup before: %s containers", len(container_list))

    for container in container_list:
        container.stop()
        container.remove()

def retrieve_onap_ip():
    """Retrieve ONAP IP from /etc/hosts"""
    filepath = '/etc/hosts'
    with open(filepath) as fp_config:
        line = fp_config.readline()
        while line:
            line = fp_config.readline()
            if "so.api.simpledemo.onap.org" in line:
                onap_ip = line.split()[0]
                return onap_ip
    return None

def execute_test(serie_number, test_number,
                 docker_client):
    """Execute one test."""
    LOGGER.info("Execute test n° %s", test_number + 1)

    volume_reporting = (ARGS.reporting + '/serie' + str(serie_number) +
                        '/test' + str(test_number + 1))
    if ARGS.ip == CLUSTER_IP:
        onap_ip = retrieve_onap_ip()
    else:
        onap_ip = ARGS.ip

    this_container = docker_client.containers.run(
        "nexus3.onap.org:10003/onap/xtesting-smoke-usecases-pythonsdk:master",
        command="run_tests -t " + ARGS.test,
        name=get_container_name(),
        labels={"test":ARGS.test},
        stdout=True,
        stderr=True,
        stream=False,
        detach=True,
        extra_hosts={'portal-ui.simpledemo.onap.org':onap_ip,
                     'vid-ui.simpledemo.onap.org':onap_ip,
                     'sdc-fe-ui.simpledemo.onap.org':onap_ip,
                     'sdc-be-api.simpledemo.onap.org':onap_ip,
                     'aai-api.simpledemo.onap.org':onap_ip,
                     'so-api.simpledemo.onap.org':onap_ip,
                     'sdnc-api.simpledemo.onap.org':onap_ip,
                     'sdc.workflow.plugin.simpledemo.onap.org':onap_ip,
                     'sdc.dcae.plugin.simpledemo.onap.org':onap_ip,
                     'multicloud-k8s-api.simpledemo.onap.org':onap_ip}
        volumes={'/tmp/xtesting/smoke-usecases/' + ARGS.test + '/env':{'bind': '/var/lib/xtesting/conf/env_file', 'mode': 'rw'},  # pylint: disable=line-too-long
                 f'{HOMEPATH}/.config/openstack/clouds.yaml':{'bind': '/root/.config/openstack/clouds.yaml', 'mode': 'rw'},  # pylint: disable=line-too-long
                 volume_reporting:{'bind':'/var/lib/xtesting/results', 'mode': 'rw'},
                 f'{HOMEPATH}/.kube/config':{'bind':'/root/.kube/config', 'mode': 'rw'},
                 os.path.dirname(os.path.abspath(__file__)) + '/artifacts/settings.py':{'bind': ONAPTESTS_SETTINGS, 'mode': 'rw'},  # pylint: disable=line-too-long
                 f'/tmp/xtesting/smoke-usecases/{ARGS.test}/{ARGS.test}-service.yaml': {'bind': f'{ONAPTESTS_SERVICE_DIR}/{ARGS.test}-service.yaml', 'mode': 'rw'}})  # pylint: disable=line-too-long

    return this_container

def launch_test_serie(serie_number,
                      docker_client, serie_containers):
    """Launch a serie of n tests."""
    for test_number in range(ARGS.simu):
        container = execute_test(serie_number, test_number,
                                 docker_client)
        serie_containers.append(container)
    return serie_containers

def get_terminated_serie_status(running_containers):
    """Check if the dockers in the list are terminated and get exit codes"""
    LOGGER.info("check terminated dockers")
    exit_codes = []
    exit_codes.clear()

    for container in running_containers:
        try:
            # wait for the container to finish within a certain time
            result = container.wait(timeout=60*ONAPTEST_BENCH_WAIT_TIMER)
            exit_code = result["StatusCode"]
        except Exception as timeout:  # pylint: disable=broad-except
            #if the container didn't finish in the allocated time
            # raise timeout exception and sto the container
            LOGGER.error(timeout)
            LOGGER.error("docker not terminating in allocated time")
            container.stop()
            exit_code = -1
        LOGGER.info("exit code : %s", str(exit_code))
        exit_codes.append(exit_code)
    return exit_codes

def generate_report():
    """Build reporting."""
    LOGGER.info("Generate the report")
    test = Reporting.OnaptestBenchReporting(
        nb_simultaneous_tests=ARGS.simu,
        duration=ARGS.duration,
        res_dir_path=ARGS.reporting,
        reporting_dir=ARGS.reporting)
    test.generate_reporting()

def main():
    """Entry point"""
    # ***************************************************************************
    # ***************************************************************************
    # start of the test
    # ***************************************************************************
    # ***************************************************************************
    test_client = docker.from_env()
    serie_containers = []
    exit_codes = []

    prepare_test_config()

    t_end = time.time() + 60 * float(ARGS.duration)

    # clean previous container no longer used to avoid saturation


    LOGGER.info("****************************")
    LOGGER.info("Launch the tests")
    LOGGER.info("Testcase: %s", ARGS.test)
    LOGGER.info("Number of simultaneous tests : %s", ARGS.simu)
    LOGGER.info("Test duration : %s m", ARGS.duration)
    LOGGER.info("Reporting path : %s", ARGS.reporting)
    LOGGER.info("****************************")

    try:
        # keep on launching series until we reached the duration expected by the tester
        serie_number = 1
        while time.time() < t_end:
            clean_test_device(test_client, ARGS.test)
            LOGGER.info("Serie : %s", str(serie_number))
            serie_containers.clear()
            # launch the serie
            serie_containers = launch_test_serie(
                serie_number,
                test_client,
                serie_containers)
            LOGGER.info("Containers of serie %s created", str(serie_number))
            exit_codes = get_terminated_serie_status(serie_containers)
            LOGGER.info("Serie terminated")
            LOGGER.debug(exit_codes)
            remaining_time = int(t_end - time.time())
            if remaining_time > 0:
                LOGGER.info("%s s remaining, restart a serie...", remaining_time)
            serie_number += 1

    except Exception as error:  # pylint: disable=broad-except
        LOGGER.error(error)
        LOGGER.error(">>>> Onaptests_bench FAIL")
        LOGGER.error("do you have the correct env file?")
        LOGGER.error("do you have the correctcluster IP?")
        sys.exit(1)

    else:
        LOGGER.info(">>>> Onaptests_bench successfully executed")

    finally:
        generate_report()
