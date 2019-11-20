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

from unittest import mock
from werkzeug.datastructures import FileStorage

from yang_loader_server import YangLoaderHelper, YangModelServer


class TestYangLoaderHelper(unittest.TestCase):

    def test_should_save_file_and_return_path(self):
        helper = YangLoaderHelper()
        mocked_file = mock.Mock(FileStorage)
        mocked_file.filename = "sample"

        path = helper.save_file(mocked_file)

        self.assertEqual(path, "/tmp/sample")
        mocked_file.save.assert_called_once_with("/tmp/sample")

    @mock.patch('yang_loader_server.check_output')
    def test_should_install_new_yang_model(self, mocked_output):
        helper = YangLoaderHelper()

        helper.install_new_model("path")

        mocked_output.assert_called_with(
            ['sysrepoctl', '--install', '--yang=path',
             '--owner=netconf:nogroup', '--permissions=777'],
            stderr=-2, universal_newlines=True)

    @mock.patch('yang_loader_server.check_output')
    def test_should_delete_yang_model(self, mocked_output):
        helper = YangLoaderHelper()

        helper.uninstall_a_model("modelName")

        mocked_output.assert_called_with(
            ['sysrepoctl', '--uninstall', '--module=modelName'],
            stderr=-2, universal_newlines=True)

    @mock.patch('yang_loader_server.check_output')
    def test_should_set_default_configuration(self, mocked_output):
        helper = YangLoaderHelper()

        helper.set_default_configuration("samplePath", "sampleModuleName")

        mocked_output.assert_called_with(
            ['sysrepocfg', '--import=samplePath', '--datastore=startup',
             '--format=xml', '--level=3', 'sampleModuleName'],
            stderr=-2, universal_newlines=True)

    @mock.patch('yang_loader_server.subprocess.Popen')
    @mock.patch('yang_loader_server.check_output')
    def test_should_verify_change_listener_for_model_properly(self, mocked_output, mocked_popen):
        helper = YangLoaderHelper()

        helper.start_change_listener_for_model("sampleModule")

        mocked_output.assert_called_with(
            ['pgrep', '-f', 'python /netconf/netopeer_change_saver.py sampleModule kafka1:9092 config'],
            stderr=-2, universal_newlines=True)

    @mock.patch('yang_loader_server.check_output')
    def test_should_raise_exception_when_error_occurred_in_output(self,
        mocked_output):
        helper = YangLoaderHelper()
        mocked_output.return_value = "abcd ERR"
        with self.assertRaises(RuntimeError) as context:
            helper._run_bash_command("sample command")

        self.assertEqual('abcd ERR', str(context.exception))


class TestYangModelServer(unittest.TestCase):

    def __init__(self, methodName='runTest'):
        super().__init__(methodName)
        self._mocked_file = mock.Mock(FileStorage)

    def test_should_properly_apply_and_start_new_model(self):
        with mock.patch.object(YangModelServer, '_parse_request',
                               new=self._mock_request):
            helper = mock.Mock(YangLoaderHelper)
            helper.save_file.return_value = "sampleFile"
            server = YangModelServer(helper)

            server.post()

            self.assertEqual(helper.save_file.call_count, 2)
            helper.install_new_model.assert_called_once_with('sampleFile')
            helper.set_default_configuration.assert_called_once_with(
                'sampleFile', 'sampleModuleName')
            helper.start_change_listener_for_model.assert_called_once_with('sampleModuleName')

    def _mock_request(self):
        return {
            'yangModel': self._mocked_file,
            'initialConfig': self._mocked_file,
            'moduleName': "sampleModuleName"
        }
