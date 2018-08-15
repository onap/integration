#!/bin/bash
#
# Copyright 2016-2017 Intel Corp., Ltd.
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
# Modifications copyright (c) 2017 AT&T Intellectual Property
#
# Place the scripts in run order:

# Clone vnfsdk/pkgtools repo and install it
mkdir -p $WORKSPACE/archives/pkgtools
cd $WORKSPACE/archives
git clone -b master --single-branch http://gerrit.onap.org/r/vnfsdk/pkgtools.git pkgtools
cd $WORKSPACE/archives/pkgtools
git pull
echo "To install vnfsdk pkgtools git head revision: $(git rev-parse HEAD)"
python setup.py egg_info
pip install .

pip freeze | tee $WORKSPACE/archives/_pip-freeze-after-setup.txt

# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v SCRIPTS:${SCRIPTS}"

