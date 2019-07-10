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
import json
import os
import unittest
from http.client import HTTPResponse, HTTPConnection
from unittest import mock
from unittest.mock import patch, Mock

from cli.pnf_simulator import SimulatorClient, FullEventRequest, Messages
from cli.pnf_simulator import create_argument_parser, SimulatorParams, PersistedEventRequest


class TestArgumentParser(unittest.TestCase):

    def test_should_properly_parse_send_template_action_with_all_params(self):
        parser = create_argument_parser()

        result = parser.parse_args(
            ['send', 'template', '--address', '127.0.0.1', "--name", 'sample_template', '--patch', '"{}"', '--repeats', '2',
             "--interval", '5', '--verbose', '--ves_server_url', 'sample_url'])

        self.assertEqual(result.address, '127.0.0.1')
        self.assertEqual(result.name, "sample_template")
        self.assertEqual(result.patch, "\"{}\"")
        self.assertEqual(result.repeats, 2)
        self.assertEqual(result.interval, 5)
        self.assertEqual(result.ves_server_url, 'sample_url')
        self.assertTrue(result.verbose)

    def test_should_properly_parse_send_event_action_with_all_params(self):
        parser = create_argument_parser()

        result = parser.parse_args(
            ['send', 'event', '--address', '127.0.0.1', "--filepath", 'sample_filepath.json', '--verbose', '--ves_server_url', 'sample_url'])

        self.assertEqual(result.address, '127.0.0.1')
        self.assertEqual(result.filepath, "sample_filepath.json")
        self.assertEqual(result.ves_server_url, 'sample_url')
        self.assertTrue(result.verbose)

    def test_should_properly_parse_configure_action_with_all_params(self):
        parser = create_argument_parser()
        result = parser.parse_args(
            ['configure', '--address', '127.0.0.1', "--verbose", '--ves-server-url', 'sample_url']
        )

        self.assertEqual(result.address, '127.0.0.1')
        self.assertTrue(result.verbose)
        self.assertEqual(result.ves_server_url, 'sample_url')

    def test_should_properly_parse_get_config_action_with_all_params(self):
        parser = create_argument_parser()
        result = parser.parse_args(
            ['get-config', '--address', '127.0.0.1', '--verbose']
        )

        self.assertEqual(result.address, '127.0.0.1')
        self.assertTrue(result.verbose)

    def test_should_not_parse_arguments_when_mandatory_params_are_missing_for_template(self):
        parser = create_argument_parser()

        with self.assertRaises(SystemExit) as context:
            parser.parse_args(['send', 'template'])
            self.assertTrue('the following arguments are required: --address, --name' in context.exception)

    def test_should_not_parse_arguments_when_mandatory_params_are_missing_for_event(self):
        parser = create_argument_parser()

        with self.assertRaises(SystemExit) as context:
            parser.parse_args(['send', 'event'])
            self.assertTrue('the following arguments are required: --address, --filepath' in context.exception)

    def test_should_not_parse_arguments_when_mandatory_template_params_are_missing(self):
        parser = create_argument_parser()

        with self.assertRaises(SystemExit) as context:
            parser.parse_args(['template'])
            self.assertTrue('one of the arguments --list --get-content is required' in context.exception)

    def test_should_not_parse_template_action_with_all_params(self):
        parser = create_argument_parser()
        with self.assertRaises(SystemExit) as context:
            parser.parse_args(
                ['template', '--address', '127.0.0.1', "--list", '--get-content', 'sample']
            )
            self.assertTrue('argument --get-content: not allowed with argument --list' in context.exception)

    def test_should_properly_parse_template_action_with_list_param(self):
        parser = create_argument_parser()
        result = parser.parse_args(
            ['template', '--address', '127.0.0.1', "--list"]
        )

        self.assertTrue(result.list)
        self.assertEqual(result.address, '127.0.0.1')
        self.assertFalse(result.verbose)

    def test_should_properly_parse_template_action_with_get_content_param(self):
        parser = create_argument_parser()
        result = parser.parse_args(
            ['template', '--address', '127.0.0.1', "--get-content", "sample"]
        )

        self.assertTrue(result.get_content)
        self.assertEqual(result.address, '127.0.0.1')
        self.assertFalse(result.verbose)

    def test_should_not_parse_template_action_with_empty_get_content_param(self):
        parser = create_argument_parser()
        with self.assertRaises(SystemExit) as context:
            parser.parse_args(
                ['template', '--address', '127.0.0.1', "--list", '--get-content']
            )
            self.assertTrue('argument --get-content: expected one argument' in context.exception)

    def test_should_not_parse_template_action_when_only_override_is_given(self):
        parser = create_argument_parser()
        with self.assertRaises(SystemExit) as context:
            parser.parse_args(
                ['template', '--address', '127.0.0.1', "--override"]
            )
            self.assertTrue(Messages.OVERRIDE_VALID_ONLY_WITH_UPLOAD in context.exception)

    def test_should_parse_template_action_with_upload(self):
        parser = create_argument_parser()
        result = parser.parse_args(
            ['template', '--address', '127.0.0.1', "--upload", "resources/notification.json"]
        )

        self.assertFalse(result.override)
        self.assertEqual(result.upload, 'resources/notification.json')

    def test_should_parse_template_action_with_upload_and_override(self):
        parser = create_argument_parser()
        result = parser.parse_args(
            ['template', '--address', '127.0.0.1', "--upload", "resources/notification.json", "--override"]
        )

        self.assertTrue(result.override)
        self.assertEqual(result.upload, 'resources/notification.json')


    def test_should_properly_parse_filter_templates_action_with_all_params(self):
        parser = create_argument_parser()

        result = parser.parse_args(
            ['filter', '--address', '127.0.0.1', '--criteria', '"{}"', '--verbose'])

        self.assertEqual(result.address, '127.0.0.1')
        self.assertEqual(result.criteria, "\"{}\"")
        self.assertTrue(result.verbose)

class TestSimulatorClient(unittest.TestCase):

    @patch('cli.pnf_simulator.http.client.HTTPConnection')
    def test_should_properly_send_event(self, http_connection):
        request = self._create_request()
        mocked_connection = Mock(HTTPConnection)
        http_connection.return_value = mocked_connection
        mocked_response = Mock(HTTPResponse)
        mocked_connection.getresponse.return_value = mocked_response
        mocked_response.status = '200'
        mocked_response.headers = {}

        client = SimulatorClient('localhost')
        client.send_event(request)

        mocked_connection.close.assert_called_with()
        mocked_connection.request.assert_called_with('POST', '/simulator/start',
                                                     body=mock.ANY,
                                                     headers={'Content-Type': 'application/json'})

    @patch('cli.pnf_simulator.http.client.HTTPConnection')
    def test_should_properly_send_one_time_event(self, http_connection):
        event_abs_filepath =  os.path.join(os.path.dirname(os.path.abspath(__file__)),"resources/notification.json")
        request = self._create_one_time_request(event_abs_filepath)
        mocked_connection = Mock(HTTPConnection)
        http_connection.return_value = mocked_connection
        mocked_response = Mock(HTTPResponse)
        mocked_connection.getresponse.return_value = mocked_response
        mocked_response.status = '202'
        mocked_response.headers = {}

        client = SimulatorClient('localhost')
        client.send_one_time_event(request)

        mocked_connection.close.assert_called_with()
        mocked_connection.request.assert_called_with('POST', '/simulator/event',
                                                     body=mock.ANY,
                                                     headers={'Content-Type': 'application/json'})

    @patch('cli.pnf_simulator.http.client.HTTPConnection')
    def test_should_properly_update_configuration(self, http_connection):
        mocked_connection = Mock(HTTPConnection)
        http_connection.return_value = mocked_connection
        mocked_response = Mock(HTTPResponse)
        mocked_connection.getresponse.return_value = mocked_response
        mocked_response.status = '200'
        mocked_response.headers = {}

        client = SimulatorClient('localhost')
        client.edit_configuration("sample_url")

        mocked_connection.close.assert_called_with()
        mocked_connection.request.assert_called_with('PUT', '/simulator/config',
                                                     body=json.dumps({"vesServerUrl": "sample_url"}),
                                                     headers={'Content-Type': 'application/json'})

    @patch('cli.pnf_simulator.http.client.HTTPConnection')
    def test_should_properly_retrieve_configuration(self, http_connection):
        mocked_connection = Mock(HTTPConnection)
        http_connection.return_value = mocked_connection
        mocked_response = Mock(HTTPResponse)
        mocked_connection.getresponse.return_value = mocked_response
        mocked_response.status = '200'
        mocked_response.headers = {}

        client = SimulatorClient('localhost')
        client.get_configuration()
        mocked_connection.close.assert_called_with()
        mocked_connection.request.assert_called_with('GET', '/simulator/config')


    @patch('cli.pnf_simulator.http.client.HTTPConnection')
    def test_should_properly_trigger_filter_template_action(self, http_connection):
        request = '{"sampleSearchString": "sampleSearchValue"}'
        mocked_connection = Mock(HTTPConnection)
        http_connection.return_value = mocked_connection
        mocked_response = Mock(HTTPResponse)
        mocked_connection.getresponse.return_value = mocked_response
        mocked_response.status = '200'
        mocked_response.headers = {}

        client = SimulatorClient('localhost')
        client.search_for_templates(request)

        mocked_connection.close.assert_called_with()
        mocked_connection.request.assert_called_with('POST', '/template/search',
                                                     body=json.dumps({"searchExpr": {"sampleSearchString": "sampleSearchValue"}}),
                                                     headers={'Content-Type': 'application/json'})


    @classmethod
    def _create_request(cls):
        return PersistedEventRequest(SimulatorParams(), 'sample_template')

    @classmethod
    def _create_one_time_request(cls, event_filepath):
        with open(event_filepath) as json_event:
            event_body = json.load(json_event)
        return FullEventRequest(event_body, 'sample_url')
