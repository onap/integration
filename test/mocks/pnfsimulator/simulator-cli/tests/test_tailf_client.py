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
import unittest
import asynctest

from cli.client.tailf_client import TailfClient


class TestTailfClient(unittest.TestCase):

    def __init__(self, methodName='runTest'):
        super().__init__(methodName)
        self._client = TailfClient('ws://localhost:9999')

    @asynctest.mock.patch('cli.client.tailf_client.websockets')
    def test_should_connect_to_server_and_receive_message(self, websockets_mock):
        recv_mock = asynctest.CoroutineMock(side_effect=self.interrupt)
        aenter_mock = asynctest.MagicMock()
        connection_mock = asynctest.MagicMock()
        websockets_mock.connect.return_value = aenter_mock
        aenter_mock.__aenter__.return_value = connection_mock
        connection_mock.recv = recv_mock

        self._client.tailf_messages()

        recv_mock.assert_awaited_once()

    def interrupt(self):
        self._client._is_running = False
        return 'test'
