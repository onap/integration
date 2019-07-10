#!/usr/bin/env python3
###
# ============LICENSE_START=======================================================
# Simulator
# ================================================================================
# Copyright (C) 2019 Nokia. All rights reserved.
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
# ============LICENSE_END=========================================================
###

import argparse
import logging
import logging.config
import requests
import os
import sys
from requests import Response

from cli.client.tailf_client import TailfClient

TAILF_FUNC_ENDPOINT = "ws://{}:9000/netconf"
LESS_FUNC_ENDPOINT = "/store/less"
CM_HISTORY_ENDPOINT = "/store/cm-history"
GET_CONFIG_ENDPOINT = "/netconf/get"
MODEL_ENDPOINT = "/netconf/model/{}"
EDIT_CONFIG_ENDPOINT = "/netconf/edit-config"
logging.basicConfig()

DEFAULT_EXTERNAL_SIM_PORT = 8080
DEFAULT_INTERNAL_SIM_PORT = 9000


class NetconfSimulatorClient(object):
    def __init__(self, ip: str, protocol: str = 'http', port: int = DEFAULT_EXTERNAL_SIM_PORT, verbose: bool = False) -> None:
        self._ip = ip
        self._protocol = protocol
        self._port = port
        self._configure_logger(verbose)
        self._verbose=verbose

    def tailf_like_func(self) -> None:
        url = TAILF_FUNC_ENDPOINT.format(self._ip)
        client = TailfClient(url, self._verbose)
        client.tailf_messages()

    def get_cm_history(self) -> None:
        self.logger.info("Attempting to retrieve all netconf configuration changes")
        simulator_address = "{}://{}:{}{}".format(self._protocol, self._ip, self._port, CM_HISTORY_ENDPOINT)
        self.logger.debug("Simulator address: %s", simulator_address)
        try:
            response = requests.get(simulator_address)
            self._log_json_response(response)
        except requests.ConnectionError:
            self.logger.error("Failed to establish connection with {}".format(simulator_address))

    def less_like_func(self, limit: int) -> None:
        self.logger.info("Attempting to run less on CM change")
        simulator_address = "{}://{}:{}{}".format(self._protocol, self._ip, self._port, LESS_FUNC_ENDPOINT)
        parameters = {"offset": limit} if limit else None
        self.logger.debug("Simulator address: %s", simulator_address)
        try:
            response = requests.get(url = simulator_address, params = parameters)
            self._log_json_response(response)
        except requests.ConnectionError:
            self.logger.error("Failed to establish connection with {}".format(simulator_address))

    def get_config(self, module_name: str=None, container:str=None)-> None:
        self.logger.info("Attempting to run get-config")
        simulator_address = self._create_get_endpoint(module_name, container)
        self.logger.debug("Simulator address: %s", simulator_address)
        try:
            response = requests.get(simulator_address)
            self._log_string_response(response)
        except requests.ConnectionError:
            self.logger.error("Failed to establish connection with {}".format(simulator_address))

    def load_yang_model(self, module_name: str, yang_model_path: str, config_path: str) -> None:
        self.logger.info(
            "Attempting to load new yang model with its initial configuration")
        simulator_address = "{}://{}:{}{}".format(self._protocol, self._ip, self._port, MODEL_ENDPOINT.format(module_name))
        files = {"yangModel": open(yang_model_path, "rb"),
                 "initialConfig": open(config_path, "rb")}
        self.logger.debug("Simulator address: %s", simulator_address)

        try:
            response = requests.post(simulator_address, files=files)
            self._log_string_response(response)
        except requests.ConnectionError:
            self.logger.error("Failed to establish connection with {}".format(simulator_address))

    def delete_yang_model(self, model_name: str) -> None:
        self.logger.info(
            "Attempting to delete a yang model")
        simulator_address = "{}://{}:{}{}".format(self._protocol, self._ip, self._port, MODEL_ENDPOINT.format(model_name))
        self.logger.debug("Simulator address: %s", simulator_address)

        try:
            response = requests.delete(simulator_address)
            self._log_string_response(response)
        except requests.ConnectionError:
            self.logger.error("Failed to establish connection with {}".format(simulator_address))

    def edit_config(self, new_config_path: str):
        self.logger.info("Attempting to apply new configuration")
        simulator_address = "{}://{}:{}{}".format(self._protocol, self._ip, self._port, EDIT_CONFIG_ENDPOINT)
        files = {"editConfigXml": open(new_config_path,"rb")}
        self.logger.debug("Simulator address: %s", simulator_address)

        try:
            response = requests.post(simulator_address, files=files)
            self._log_string_response(response)
        except requests.ConnectionError:
            self.logger.error("Failed to establish connection with {}".format(simulator_address))

    def _log_json_response(self, response: Response) ->None:
        self.logger.info("Response status: %d", response.status_code)
        self.logger.info(" ----- HEAD -----")
        for message in response.json():
            self.logger.info("{}: {}".format(str(message['timestamp']), message['configuration']))
        self.logger.info(" ----- END ------")
        self.logger.debug(response.headers)

    def _configure_logger(self, verbose):
        logging_conf = os.path.join(sys.prefix, 'logging.ini')
        if os.path.exists(logging_conf):
            logging.config.fileConfig(logging_conf)
        else:
            print("Couldn't find logging.ini, using default logger config")
        self.logger = logging.getLogger()
        self.logger.setLevel(logging.DEBUG if verbose else logging.INFO)

    def _log_string_response(self, response: Response)->None:
        self.logger.info("Response status: %d", response.status_code)
        self.logger.info(response.text)
        self.logger.debug(response.headers)

    def _create_get_endpoint(self, module_name: str, container: str):
        endpoint = "{}://{}:{}{}".format(self._protocol, self._ip, self._port,
                                         GET_CONFIG_ENDPOINT)
        if module_name and container:
            endpoint = endpoint + "/{}/{}".format(module_name, container)
        elif (not module_name and container) or (module_name and not container):
            raise AttributeError(
                "Both module_name and container must be present or absent")
        return endpoint

def create_argument_parser():
    parser = argparse.ArgumentParser(description="Netconf Simulator Command Line Interface. ")
    subparsers = parser.add_subparsers(title="Available actions")
    tailf_parser = subparsers.add_parser("tailf",
                                        description="Method which allows user to view N last lines of configuration changes")

    __configure_tailf_like_parser(tailf_parser)
    less_parser = subparsers.add_parser("less", description="Method which allows user to traverse configuration changes")
    __configure_less_like_parser(less_parser)
    cm_history_parser = subparsers.add_parser("cm-history",
                                              description="Method which allows user to view all configuration changes")
    __configure_cm_history_parser(cm_history_parser)

    load_model_parser = subparsers.add_parser("load-model")
    __configure_load_model_parser(load_model_parser)

    delete_model_parser = subparsers.add_parser("delete-model")
    __configure_delete_model_parser(delete_model_parser)

    get_config_parser = subparsers.add_parser("get-config")
    __configure_get_config_parser(get_config_parser)
    edit_config_parser = subparsers.add_parser("edit-config")
    __configure_edit_config_parser(edit_config_parser)
    return parser


def run_tailf(args):
    client = NetconfSimulatorClient(args.address, verbose=args.verbose)
    client.tailf_like_func()


def run_get_cm_history(args):
    client = NetconfSimulatorClient(args.address, verbose=args.verbose, port=DEFAULT_INTERNAL_SIM_PORT)
    client.get_cm_history()


def run_less(args):
    client = NetconfSimulatorClient(args.address, verbose=args.verbose, port=DEFAULT_INTERNAL_SIM_PORT)
    client.less_like_func(args.limit)


def run_load_model(args):
    client = NetconfSimulatorClient(args.address, verbose=args.verbose,
                                    port=DEFAULT_INTERNAL_SIM_PORT)
    client.load_yang_model(args.module_name, args.yang_model, args.config)


def run_delete_model(args):
    client = NetconfSimulatorClient(args.address, verbose=args.verbose,
                                    port=DEFAULT_INTERNAL_SIM_PORT)
    client.delete_yang_model(args.model_name)


def run_get_config(args):
    client = NetconfSimulatorClient(args.address, verbose=args.verbose, port=DEFAULT_INTERNAL_SIM_PORT)
    client.get_config(args.module_name, args.container)


def run_edit_config(args):
    client = NetconfSimulatorClient(args.address, verbose=args.verbose, port=DEFAULT_INTERNAL_SIM_PORT)
    client.edit_config(args.config)


def __configure_tailf_like_parser(tailf_func_parser):
    tailf_func_parser.add_argument("--address", required=True, help="IP address of simulator")
    tailf_func_parser.add_argument("--verbose", action='store_true',
                                   help="Displays additional logs")
    tailf_func_parser.set_defaults(func=run_tailf)


def __configure_less_like_parser(less_func_parser):
    less_func_parser.add_argument("--address", required=True, help="IP address of simulator")
    less_func_parser.add_argument("--limit", help="Limit of configurations to retrieve")
    less_func_parser.add_argument("--verbose", action='store_true', help="Displays additional logs")
    less_func_parser.set_defaults(func=run_less)


def __configure_cm_history_parser(cm_history_parser):
    cm_history_parser.add_argument("--address", required=True, help="IP address of simulator")
    cm_history_parser.add_argument("--verbose", action='store_true', help="Displays additional logs")
    cm_history_parser.set_defaults(func=run_get_cm_history)


def __configure_load_model_parser(load_model_parser):
    load_model_parser.add_argument("--address", required=True, help="IP address of simulator")
    load_model_parser.add_argument("--module-name", required=True, help="Module name corresponding to  yang-model")
    load_model_parser.add_argument("--verbose", action='store_true', help="Displays additional logs")
    load_model_parser.add_argument("--yang-model", required=True, help="Path to file with yang model")
    load_model_parser.add_argument("--config", required=True, help="Path to file with initial xml config")
    load_model_parser.set_defaults(func=run_load_model)


def __configure_delete_model_parser(delete_model_parser):
    delete_model_parser.add_argument("--address", required=True, help="IP address of simulator")
    delete_model_parser.add_argument("--model-name", required=True, help="YANG model name to delete")
    delete_model_parser.add_argument("--verbose", action='store_true', help="Displays additional logs")
    delete_model_parser.set_defaults(func=run_delete_model)


def __configure_get_config_parser(get_config_parser):
    get_config_parser.add_argument("--address", required=True, help="IP address of simulator")
    get_config_parser.add_argument("--verbose", action='store_true',help="Displays additional logs")
    get_config_parser.add_argument("--module-name", help="Module name corresponding to  yang-model", default=None)
    get_config_parser.add_argument("--container", help="Container name corresponding to module name", default=None)
    get_config_parser.set_defaults(func=run_get_config)


def __configure_edit_config_parser(edit_config_parser):
    edit_config_parser.add_argument("--address", required=True, help="IP address of simulator")
    edit_config_parser.add_argument("--verbose", action='store_true', help="Displays additional logs")
    edit_config_parser.add_argument("--config", required=True, help="Path to file with xml config to apply")
    edit_config_parser.set_defaults(func=run_edit_config)


if __name__ == "__main__":
    argument_parser = create_argument_parser()
    result = argument_parser.parse_args()
    if hasattr(result, 'func'):
        result.func(result)
    else:
        argument_parser.parse_args(['-h'])
