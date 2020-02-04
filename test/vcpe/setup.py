#!/usr/bin/env python

# COPYRIGHT NOTICE STARTS HERE
#
# Copyright 2020 Samsung Electronics Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# COPYRIGHT NOTICE ENDS HERE

# This file is only meant to be a single source of truth for package
# dependencies. It's consumed by bin/setup.sh and tox hence shouldn't
# be run directly for package builds as currently vcpe scripts are not
# provided as a python package.

import setuptools

# Define vCPE scripts dependencies below
setuptools.setup(
    install_requires=[
        'ipaddress',
        'pyyaml',
        'mysql-connector-python',
        'progressbar2',
        'python-novaclient',
        'python-openstackclient',
        'python-heatclient',
        'kubernetes',
        'netaddr'
    ]
)
