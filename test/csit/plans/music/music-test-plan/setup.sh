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

#
# add here eventual scripts needed for music
#
echo "##########################################################";
echo "#";
echo "# music scripts calling";
echo "#";
echo "##########################################################";
source ${WORKSPACE}/test/csit/scripts/music/music-scripts/music_script.sh

#
# add here below the start of all docker containers needed for music CSIT testing
#
echo "##########################################################";
echo "#";
echo "# music scripts docker containers spinoff";
echo "#";
echo "##########################################################";

#
# add here all the configuration steps eventually needed to be carried out for music CSIT testing
#
echo "##########################################################";
echo "#";
echo "# music configuration step";
echo "#";
echo "##########################################################";


#
# add here all ROBOT_VARIABLES settings
#
echo "##########################################################";
echo "#";
echo "# music robot variables settings";
echo "#";
echo "##########################################################";
ROBOT_VARIABLES="-v MUSIC_HOSTNAME:http://localhost -v MUSIC_PORT:8080 -v COND_HOSTNAME:http://localhost -v COND_PORT:8091"

echo ${ROBOT_VARIABLES}



