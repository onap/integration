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
import logging
import unittest
import os
from mock import patch

from cli.netconf_simulator import create_argument_parser, NetconfSimulatorClient


class TestArgumentParser(unittest.TestCase):

    def test_should_properly_parse_edit_config_with_all_params(self):
        parser = create_argument_parser()
        args = parser.parse_args(
            ['edit-config', '--address', '127.0.0.1', '--config', 'sample_path',
             "--verbose"]
        )

        self.assertEqual(args.address, '127.0.0.1')
        self.assertEqual(args.config, 'sample_path')
        self.assertTrue(args.verbose)

    def test_should_properly_parse_load_yang_model(self):
        parser = create_argument_parser()

        args = parser.parse_args(
            ['load-model', '--address', '127.0.0.1', '--module-name',
             'sample_name', '--yang-model', 'sample_model', '--config',
             'sample_config',
             "--verbose"]
        )

        self.assertEqual(args.address, '127.0.0.1')
        self.assertEqual(args.config, 'sample_config')
        self.assertEqual(args.yang_model, 'sample_model')
        self.assertEqual(args.module_name, 'sample_name')
        self.assertTrue(args.verbose)

    def test_should_properly_parse_delete_yang_model(self):
        parser = create_argument_parser()

        args = parser.parse_args(
            ['delete-model', '--address', '127.0.0.1', '--model-name',
             'sample_name', "--verbose"]
        )

        self.assertEqual(args.address, '127.0.0.1')
        self.assertEqual(args.model_name, 'sample_name')
        self.assertTrue(args.verbose)

    def test_should_properly_parse_get_config(self):
        parser = create_argument_parser()
        args = parser.parse_args(
            ['get-config', '--address', '127.0.0.1', '--verbose']
        )

        self.assertEqual(args.address, '127.0.0.1')
        self.assertTrue(args.verbose)


class TestNetconfSimulatorClient(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        with open("example", "w+") as f:
            f.write("sampleContent")

    @classmethod
    def tearDownClass(cls):
        os.remove("example")

    @patch('cli.netconf_simulator.requests')
    @patch('cli.netconf_simulator.NetconfSimulatorClient._configure_logger')
    def test_should_properly_get_config(self, logger, requests):
        client = NetconfSimulatorClient('localhost')
        client.logger = logging.getLogger()

        client.get_config()

        requests.get.assert_called_with('http://localhost:8080/netconf/get')

    @patch('cli.netconf_simulator.requests')
    @patch('cli.netconf_simulator.NetconfSimulatorClient._configure_logger')
    def test_should_properly_get_config_for_given_module(self, logger, requests):
        client = NetconfSimulatorClient('localhost')
        client.logger = logging.getLogger()

        client.get_config("module", "container")

        requests.get.assert_called_with('http://localhost:8080/netconf/get/module/container')

    @patch('cli.netconf_simulator.NetconfSimulatorClient._configure_logger')
    def test_should_raise_exception_when_module_is_present_and_container_is_absent(self, logger):
        client = NetconfSimulatorClient('localhost')
        client.logger = logging.getLogger()

        with self.assertRaises(AttributeError) as context: # pylint: disable=W0612
            client.get_config(module_name="test")

    @patch('cli.netconf_simulator.NetconfSimulatorClient._configure_logger')
    def test_should_raise_exception_when_module_is_absent_and_container_is_present(self, logger):
        client = NetconfSimulatorClient('localhost')
        client.logger = logging.getLogger()

        with self.assertRaises(AttributeError) as context: # pylint: disable=W0612
            client.get_config(container="test")

    @patch('cli.netconf_simulator.requests')
    @patch('cli.netconf_simulator.NetconfSimulatorClient._configure_logger')
    def test_should_properly_load_yang_model(self, logger, requests):
        client = NetconfSimulatorClient('localhost')
        client.logger = logging.getLogger()

        client.load_yang_model('sample_module_name', 'example', 'example')

        requests.post.assert_called()

    @patch('cli.netconf_simulator.requests')
    @patch('cli.netconf_simulator.NetconfSimulatorClient._configure_logger')
    def test_should_properly_delete_yang_model(self, logger, requests):
        client = NetconfSimulatorClient('localhost')
        client.logger = logging.getLogger()

        client.delete_yang_model('sample_model_name')

        requests.delete.assert_called()

    @patch('cli.netconf_simulator.requests')
    @patch('cli.netconf_simulator.NetconfSimulatorClient._configure_logger')
    def test_should_properly_edit_config(self, logger, requests):
        client = NetconfSimulatorClient('localhost')
        client.logger = logging.getLogger()

        client.edit_config('example')

        requests.post.assert_called()

    @patch('cli.netconf_simulator.requests')
    @patch('cli.netconf_simulator.NetconfSimulatorClient._configure_logger')
    def test_should_properly_run_less_like_mode(self, logger, requests):
        client = NetconfSimulatorClient('localhost')
        client.logger = logging.getLogger()

        client.less_like_func(100)

        requests.get.assert_called_with(
            params={"offset": 100}, url="http://localhost:8080/store/less")
