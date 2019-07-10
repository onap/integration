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
import http.client
import json
import logging
import ntpath
from typing import Dict

SEND_PERIODIC_EVENT_ENDPOINT = "/simulator/start"
SEND_ONE_TIME_EVENT_ENDPOINT = "/simulator/event"
CONFIG_ENDPOINT = "/simulator/config"
LIST_TEMPLATES_ENDPOINT = "/template/list"
GET_TEMPLATE_BY_NAME_ENDPOINT = "/template/get"
UPLOAD_TEMPLATE_NOFORCE = "/template/upload"
UPLOAD_TEMPLATE_FORCE = "/template/upload?override=true"
FILTER_TEMPLATES_ENDPOINT = "/template/search"

logging.basicConfig()


class Messages(object):
    OVERRIDE_VALID_ONLY_WITH_UPLOAD = "--override is valid only with --upload parameter"


class SimulatorParams(object):
    def __init__(self, repeats: int = 1, interval: int = 1, ves_server_url: str = None) -> None:
        self.repeats_count = repeats
        self.repeats_interval = interval
        self.ves_server_url = ves_server_url

    def to_json(self) -> Dict:
        to_return = {"repeatCount": self.repeats_count,
                     "repeatInterval": self.repeats_interval}
        if self.ves_server_url:
            to_return["vesServerUrl"] = self.ves_server_url
        return to_return

    def __repr__(self) -> str:
        return str(self.to_json())


class PersistedEventRequest(object):
    def __init__(self, simulator_params: SimulatorParams, template: str, patch: Dict = None) -> None:
        self.params = simulator_params
        self.template = template
        self.patch = patch or {}

    def to_json(self) -> Dict:
        return {"simulatorParams": self.params, "templateName": self.template,
                "patch": self.patch}

    def __repr__(self) -> str:
        return str(self.to_json())


class FullEventRequest(object):
    def __init__(self, event_body: Dict, ves_server_url: str = None) -> None:
        self.event_body = event_body
        self.ves_server_url = ves_server_url or ""

    def to_json(self) -> Dict:
        return {"vesServerUrl": self.ves_server_url, "event": self.event_body}

    def __repr__(self) -> str:
        return str(self.to_json())


class TemplateUploadRequest(object):
    def __init__(self, template_name: str, template_body: Dict) -> None:
        self.template_name = template_name
        self.template_body = template_body

    def to_json(self) -> Dict:
        return {"name": self.template_name, "template": self.template_body}

    def __repr__(self) -> str:
        return str(self.to_json())


class SimulatorClient(object):
    def __init__(self, ip: str, port: int = 5000, verbose: bool = False) -> None:
        self._ip = ip
        self._port = port
        self.logger = logging.getLogger()
        self.logger.setLevel(logging.DEBUG if verbose else logging.INFO)

    def send_event(self, request: PersistedEventRequest) -> None:
        connection = http.client.HTTPConnection(self._ip, self._port)
        self.logger.info("Attempting to send event")
        self.logger.debug("Simulator address: ip %s, port %s, endpoint %s", self._ip, self._port, SEND_PERIODIC_EVENT_ENDPOINT)
        self.logger.debug("REQUEST %s", request)

        connection.request("POST", SEND_PERIODIC_EVENT_ENDPOINT, body=json.dumps(request, cls=RequestSerializer),
                           headers={"Content-Type": "application/json"})

        response = connection.getresponse()

        self._log_response(response)
        connection.close()

    def send_one_time_event(self, request: FullEventRequest) -> None:
        connection = http.client.HTTPConnection(self._ip, self._port)
        self.logger.info("Attempting to send one time event")
        self.logger.debug("Simulator address: ip %s, port %s, endpoint %s", self._ip, self._port, SEND_ONE_TIME_EVENT_ENDPOINT)
        self.logger.debug("REQUEST %s", request.to_json())

        connection.request("POST", SEND_ONE_TIME_EVENT_ENDPOINT, body=json.dumps(request.to_json()),
                           headers={"Content-Type": "application/json"})

        response = connection.getresponse()

        self._log_response(response)
        connection.close()

    def get_configuration(self) -> None:
        connection = http.client.HTTPConnection(self._ip, self._port)
        self.logger.info("Attempting to retrieve Simulator configuration")
        self.logger.debug("Simulator address: ip %s, port %s, endpoint %s", self._ip, self._port, CONFIG_ENDPOINT)
        connection.request("GET", CONFIG_ENDPOINT)
        response = connection.getresponse()

        self._log_response(response)
        connection.close()

    def edit_configuration(self, ves_server_url: str) -> None:
        connection = http.client.HTTPConnection(self._ip, self._port)
        self.logger.info("Attempting to update Simulator configuration")
        self.logger.debug("Simulator address: ip %s, port %s, endpoint %s", self._ip, self._port, CONFIG_ENDPOINT)
        request = {"vesServerUrl": ves_server_url}
        self.logger.debug("REQUEST %s", request)
        connection.request("PUT", CONFIG_ENDPOINT, body=json.dumps(request),
                           headers={"Content-Type": "application/json"})

        response = connection.getresponse()

        self._log_response(response)
        connection.close()

    def _log_response(self, response: http.client.HTTPResponse):
        self.logger.info("Response status: %s ", response.status)
        self.logger.info(response.read().decode())
        self.logger.debug(response.headers)

    def list_templates(self):
        connection = http.client.HTTPConnection(self._ip, self._port)
        self.logger.info("Attempting to retrieve all templates")
        self.logger.debug("Simulator address: ip %s, port %s, endpoint %s", self._ip, self._port, LIST_TEMPLATES_ENDPOINT)
        connection.request("GET", LIST_TEMPLATES_ENDPOINT)
        response = connection.getresponse()

        self._log_response(response)
        connection.close()

    def get_template_by_name(self, name):
        connection = http.client.HTTPConnection(self._ip, self._port)
        endpoint = GET_TEMPLATE_BY_NAME_ENDPOINT + "/" + name
        self.logger.info("Attempting to retrieve template by name: '%s'", name)
        self.logger.debug("Simulator address: ip %s, port %s, endpoint %s", self._ip, self._port, endpoint)
        connection.request("GET", endpoint)
        response = connection.getresponse()

        self._log_response(response)
        connection.close()

    def upload_template(self, template_request, force):
        connection = http.client.HTTPConnection(self._ip, self._port)
        endpoint = UPLOAD_TEMPLATE_FORCE if force else UPLOAD_TEMPLATE_NOFORCE
        self.logger.info("Attempting to upload template: '%s'", template_request)
        self.logger.debug("Simulator address: ip %s, port %s, endpoint %s", self._ip, self._port, endpoint)
        connection.request("POST", endpoint,
                           body=json.dumps(template_request.to_json()),
                           headers={"Content-Type": "application/json"})
        response = connection.getresponse()

        self._log_response(response)
        connection.close()

    def search_for_templates(self, filter_criteria: str):
        connection = http.client.HTTPConnection(self._ip, self._port)
        self.logger.debug("Simulator address: ip %s, port %s, endpoint %s", self._ip, self._port, FILTER_TEMPLATES_ENDPOINT)
        filter_request = {"searchExpr": json.loads(filter_criteria)}
        self.logger.debug("Filter criteria: %s", str(filter_criteria))
        connection.request("POST", FILTER_TEMPLATES_ENDPOINT,
                           body=json.dumps(filter_request),
                           headers={"Content-Type": "application/json"})
        response = connection.getresponse()

        self._log_response(response)
        connection.close()


class RequestSerializer(json.JSONEncoder):
    def default(self, o):
        return o.to_json() if (isinstance(o, SimulatorParams) or isinstance(o, PersistedEventRequest)) else o



def create_argument_parser():
    parser = argparse.ArgumentParser(description="PNF Simulator Command Line Interface. ")
    subparsers = parser.add_subparsers(title="Available actions")
    send_parser = subparsers.add_parser("send",
                                        description="Method which allows user to trigger simulator to start sending "
                                                    "events. Available options: [template, event]")

    send_subparsers = send_parser.add_subparsers()
    one_time_send_event_parser = send_subparsers.add_parser("event", description="Option for direct, one-time event sending to VES. This option does not require having corresponging template.")
    __configure_one_time_send_parser(one_time_send_event_parser)
    persisted_send_event_parser = send_subparsers.add_parser("template")
    __configure_persisted_send_parser(persisted_send_event_parser)

    configure_parser = subparsers.add_parser("configure", description="Method which allows user to set new default "
                                                                      "value for VES Endpoint")
    __configure_config_parser(configure_parser)

    get_config_parser = subparsers.add_parser("get-config",
                                              description="Method which allows user to view simulator configuration")
    __configure_get_config_parser(get_config_parser)

    template_config_parser = subparsers.add_parser("template", description="Template management operations")
    __configure_template_parser(template_config_parser)

    template_filter_parser = subparsers.add_parser("filter", description="Method for searching through templates to find those satisfying given criteria")
    __configure_template_filter_parser(template_filter_parser)

    return parser


def _perform_send_action(args):
    if (not args.interval and args.repeats) or (args.interval and not args.repeats):
        raise Exception("Either both repeats and interval must be present or missing")

    client = SimulatorClient(args.address, verbose=args.verbose)
    client.send_event(_create_scheduled_event_request(args))


def _perform_one_time_send_action(args):
    client = SimulatorClient(args.address, verbose=args.verbose)
    client.send_one_time_event(_create_one_time_event_request(args.filepath, args.ves_server_url))


def get_configuration(args):
    client = SimulatorClient(args.address, verbose=args.verbose)
    client.get_configuration()


def edit_configuration(args):
    client = SimulatorClient(args.address, verbose=args.verbose)
    client.edit_configuration(args.ves_server_url)


def perform_template_action(args):
    client = SimulatorClient(args.address, verbose=args.verbose)
    if args.list:
        client.list_templates()
    elif args.get_content:
        client.get_template_by_name(args.get_content)
    elif args.upload:
        client.upload_template(_create_upload_template_request(args.upload), args.override)
    elif args.force:
        raise Exception(Messages.OVERRIDE_VALID_ONLY_WITH_UPLOAD)


def list_all_templates(args):
    client = SimulatorClient(args.address, verbose=args.verbose)
    client.list_templates()


def filter_templates(args):
    client = SimulatorClient(args.address, verbose=args.verbose)
    client.search_for_templates(args.criteria)


def _create_upload_template_request(template_filename):
    with open(template_filename) as json_template:
        template_body = json.load(json_template)
    return TemplateUploadRequest(path_leaf(template_filename), template_body)


def _create_scheduled_event_request(args):
    simulator_params = SimulatorParams(args.repeats, args.interval, args.ves_server_url)
    return PersistedEventRequest(simulator_params, args.name, json.loads(args.patch) if args.patch else {})


def _create_one_time_event_request(event_filename, ves_server_url):
    with open(event_filename) as json_event:
        event_body = json.load(json_event)
    return FullEventRequest(event_body, ves_server_url)


def __configure_persisted_send_parser(send_parser):
    send_parser.add_argument("--address", required=True,  help="IP address of simulator")
    send_parser.add_argument("--name", required=True,  help="Name of template file which should be used as a base for event")
    send_parser.add_argument("--patch", help="Json which should be merged into template to override parameters")
    send_parser.add_argument("--repeats", help="Number of events to be send", type=int)
    send_parser.add_argument("--interval", help="Interval between two consecutive events (in seconds)", type=int)
    send_parser.add_argument("--ves_server_url",
                             help="Well-formed URL which will override current VES endpoint stored in simulator's DB")
    send_parser.add_argument("--verbose", action='store_true', help="Displays additional logs")
    send_parser.set_defaults(func=_perform_send_action)


def __configure_one_time_send_parser(send_parser):
    send_parser.add_argument("--address", required=True, help="IP address of simulator")
    send_parser.add_argument("--filepath", required=True,  help="Name of file with complete event for direct sending.")
    send_parser.add_argument("--ves_server_url",
                             help="Well-formed URL which will override current VES endpoint stored in simulator's DB")
    send_parser.add_argument("--verbose", action='store_true', help="Displays additional logs")
    send_parser.set_defaults(func=_perform_one_time_send_action)


def __configure_config_parser(config_parser):
    config_parser.add_argument("--address", required=True, help="IP address of simulator")
    config_parser.add_argument("--ves-server-url", required=True,
                               help="Well-formed URL which should be set as a default VES Server URL in simulator")
    config_parser.add_argument("--verbose", action='store_true', help="Displays additional logs")
    config_parser.set_defaults(func=edit_configuration)


def __configure_get_config_parser(get_config_parser):
    get_config_parser.add_argument("--address", required=True, help="IP address of simulator")
    get_config_parser.add_argument("--verbose", action='store_true', help="Displays additional logs")
    get_config_parser.set_defaults(func=get_configuration)


def __configure_template_parser(template_config_parser):
    group = template_config_parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--list", action='store_true', help="List all templates")
    group.add_argument("--get-content", help="Gets the template by name")
    group.add_argument("--upload", help="Uploads the template given in parameter file.")

    template_config_parser.add_argument("--override", action='store_true', help="Overwrites the template in case it exists.")
    template_config_parser.add_argument("--address", required=True, help="IP address of simulator")
    template_config_parser.add_argument("--verbose", action='store_true', help="Displays additional logs")
    template_config_parser.set_defaults(func=perform_template_action)


def __configure_template_filter_parser(template_filter_parser):
    template_filter_parser.add_argument("--criteria", required=True, help="Json string with key-value search criteria")
    template_filter_parser.add_argument("--address", required=True, help="IP address of simulator")
    template_filter_parser.add_argument("--verbose", action='store_true', help="Displays additional logs")
    template_filter_parser.set_defaults(func=filter_templates)


def path_leaf(path):
    head, tail = ntpath.split(path)
    return tail or ntpath.basename(head)


if __name__ == "__main__":
    argument_parser = create_argument_parser()
    result = argument_parser.parse_args()
    if hasattr(result, 'func'):
        result.func(result)
    else:
        argument_parser.parse_args(['-h'])
