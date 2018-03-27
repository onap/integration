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
DATASTORE="vault"
DATASTORE_IP="localhost"

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
popdf

cat << EOF > smsconfig.json
{
    "cafile": "auth/selfsignedca.pem",
    "servercert": "auth/server.cert",
    "serverkey":  "auth/server.key",

    "vaultaddress":     "http://localhost:8200",
    "vaulttoken":       "f56d2c0e-d58d-2be2-aed4-bb9931bedad2"
}

docker login -u docker -p docker nexus3.onap.org:10001
docker pull nexus3.onap.org:10001/onap/aaf/sms
docker pull docker.io/vault:0.9.5
docker run --name vault -d -p 8200:8200 vault:0.9.5
docker run --workdir /sms --mount --name sms -d -p 10443:10443 nexus3.onap.org:10001/onap/aaf/sms
docker run -e DATASTORE=$DATASTORE -e DATASTORE_IP=$DATASTORE_IP -e MOUNTPATH=$MOUNTPATH -d \
           --name dkv \
           -v $DEFAULT_CONFIGS:/dkv_mount_path/configs/default \
           -p 8200:8200 -p 8080:8080 nexus3.onap.org:10001/onap/music/distributed-kv-store


echo "###### WAITING FOR SECRET MANAGEMENT SERVICE CONTAINER TO COME UP"
sleep 10

#
# add here all ROBOT_VARIABLES settings
#
echo "# sms robot variables settings";
ROBOT_VARIABLES="-v SMS_HOSTNAME:http://localhost -v SMS_PORT:10443"

echo ${ROBOT_VARIABLES}