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

import setuptools

setuptools.setup(
    name="pnf_simulator_cli",
    version="5.0.0",
    description="Command line interface which allows to communicate with PNF SIMULATOR",
    packages=setuptools.find_packages(),
    data_files=['cli/data/logging.ini'],
    classifiers=["Programming Language :: Python :: 3"],
    install_requires=[
        'requests==2.20.1',
        'websockets==7.0'
    ]
)
