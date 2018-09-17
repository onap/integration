#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
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

/usr/bin/Xvfb :0 -screen 0 1024x768x24&
export DISPLAY=:0

source ${WORKSPACE}/test/csit/scripts/vid/clone_and_setup_vid_data.sh

source ${WORKSPACE}/test/csit/scripts/vid/start_vid_containers.sh

BE_IP=`get-instance-ip.sh vid-server`
echo BE_IP=${BE_IP}


# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v BE_IP:${BE_IP}"

pip install assertpy
pip install requests