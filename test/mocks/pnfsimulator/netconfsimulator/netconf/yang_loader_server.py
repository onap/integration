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
import subprocess
import os
from subprocess import check_output, CalledProcessError
from flask import Flask
from flask_restful import Resource, Api, reqparse
from werkzeug.datastructures import FileStorage
import time

app = Flask(__name__)
api = Api(app)
logger = logging.getLogger("yang-loader")
logger.addHandler(logging.StreamHandler())
KAFKA_BROKER_NAME="kafka1:9092"
KAFKA_TOPIC_NAME="config"


class YangLoaderHelper(object):

    @classmethod
    def save_file(cls, yang_model_file: FileStorage) -> str:
        path = "/tmp/" + yang_model_file.filename
        yang_model_file.save(path)
        return path

    @classmethod
    def install_new_model(cls, yang_model_path: str):
        logger.info("Installing new model: %s", yang_model_path)
        command = "sysrepoctl --install --yang={} --owner=netconf:nogroup --permissions=777" \
            .format(yang_model_path)
        cls._run_bash_command(command)

    @classmethod
    def uninstall_a_model(cls, yang_model_name: str):
        logger.info("Uninstalling a model: %s", yang_model_name)
        command = "sysrepoctl --uninstall --module={}" \
            .format(yang_model_name)
        cls._run_bash_command(command)


    @classmethod
    def set_default_configuration(cls, init_conf_path: str, module_name: str):
        logger.info("Attempting to set default configuration %s for module %s", init_conf_path, module_name)
        command = "sysrepocfg --import={} --datastore=startup --format=xml --level=3 {}" \
            .format(init_conf_path, module_name)
        cls._run_bash_command(command)

    @classmethod
    def start_change_listener_for_model(cls, module_name: str):
        logger.info("Starting listener for model: %s", module_name)
        command = "python /netconf/netopeer_change_saver.py {} {} {}" \
            .format(module_name, KAFKA_BROKER_NAME, KAFKA_TOPIC_NAME)
        try:
            check_output(["pgrep", "-f" , command], stderr=subprocess.STDOUT, universal_newlines=True)
            logger.info("Change listener for {} already exist.".format(module_name))
        except CalledProcessError:
            subprocess.Popen(command.split(), stdout=subprocess.PIPE)

    @classmethod
    def stop_change_listener_for_model(cls, model_name):
        logger.info("Stopping listener for model %s", model_name)
        pid = cls.get_pid_by_name(model_name)
        logger.info("pid is %s", pid)
        command = "kill -2 {}".format(pid)
        cls._run_bash_command(command)

    @classmethod
    def _run_bash_command(cls, command: str):
        try:
            logger.info("Attempts to invoke %s", command)
            output = check_output(command.split(), stderr=subprocess.STDOUT,
                                  universal_newlines=True)
            logger.info("Output: %s", output)
            if "ERR" in output:
                raise RuntimeError(str(output))
        except subprocess.CalledProcessError as e:
            raise RuntimeError(e, str(e.stdout))

    @classmethod
    def get_pid_by_name(cls, name):
        for dirname in os.listdir('/proc'):
            if not dirname.isdigit():
                continue
            try:
                with open('/proc/{}/cmdline'.format(dirname), mode='rb') as fd:
                    content = fd.read().decode().split('\x00')
            except Exception as e:
                print(e)
                continue

            if name in content:
                return dirname


class YangModelServer(Resource):
    logger = logging.getLogger('YangModelServer')

    def __init__(self, yang_loader_helper: YangLoaderHelper = YangLoaderHelper()):
        self._yang_loader_helper = yang_loader_helper

    def post(self):
        args = self._parse_request()
        yang_model_file = args['yangModel']
        initial_config_file = args['initialConfig']
        module_name = args['moduleName']
        model_path = self._yang_loader_helper.save_file(yang_model_file)
        conf_path = self._yang_loader_helper.save_file(initial_config_file)

        try:
            self._yang_loader_helper.install_new_model(model_path)
            self._yang_loader_helper.set_default_configuration(conf_path,
                                                               module_name)
            self._yang_loader_helper.start_change_listener_for_model(module_name)
        except RuntimeError as e:
            self.logger.error(e.args, exc_info=True)
            return str(e.args), 400
        return "Successfully started"

    def delete(self):
        args = self._parse_request()
        yang_model_name = args['yangModelName']

        try:
            self._yang_loader_helper.stop_change_listener_for_model(yang_model_name)
            time.sleep(5)
            self._yang_loader_helper.uninstall_a_model(yang_model_name)
        except RuntimeError as e:
            self.logger.error(e.args, exc_info=True)
            return str(e.args), 400
        return "Successfully deleted"

    @classmethod
    def _parse_request(cls) -> reqparse.Namespace:
        parse = reqparse.RequestParser()
        parse.add_argument('yangModel',
                           type=FileStorage,
                           location='files')
        parse.add_argument('initialConfig',
                           type=FileStorage,
                           location='files')
        parse.add_argument('moduleName', type=str)
        parse.add_argument('yangModelName', type=str)
        return parse.parse_args()


api.add_resource(YangModelServer, '/model')

if __name__ == '__main__':
    logging.basicConfig(filename=os.path.dirname(__file__) + "/yang_loader.log",
                        filemode="w",
                        level=logging.DEBUG)
    app.run(host='0.0.0.0', port='5002')
