#!/bin/bash
#
# Copyright 2018 Intel Corporation
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

# Not sure why this is needed.
source ${SCRIPTS}/common_functions.sh

# Initial Configuration.
CONSUL_IP="localhost"
MOUNTPATH="/dkv_mount_path/configs/"
DEFAULT_CONFIGS=$(pwd)/mountpath/default

mkdir -p mountpath/default

pushd mountpath/default
cat << EOF > sampleConfig1.properties
foo1=bar1
hello1=world1
key1=value1
EOF
cat << EOF > sampleConfig2.properties
foo2=bar2
hello2=world2
key2=value2
EOF
popd

docker run -e CONSUL_IP=$CONSUL_IP -e MOUNTPATH=$MOUNTPATH -it \
           --name dkv \
           -v $DEFAULT_CONFIGS:/dkv_mount_path/configs/default \
           -p 8200:8200 -p 8080:8080 nexus3.onap.org:10003/onap/music/distributed-kv-store

#
# add here all ROBOT_VARIABLES settings
#
echo "# music robot variables settings";
ROBOT_VARIABLES="-v DKV_HOSTNAME:http://localhost -v DKV_PORT:8080"

echo ${ROBOT_VARIABLES}