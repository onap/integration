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

CONFIG_FILE=$(pwd)/config/smsconfig.json

mkdir -p $(pwd)/config

docker login -u docker -p docker nexus3.onap.org:10001
docker pull nexus3.onap.org:10001/onap/aaf/sms
docker pull docker.io/vault:0.10.0

#
# Running vault in dev server mode here for CSIT
# In HELM it runs in production mode
#
docker run -e "VAULT_DEV_ROOT_TOKEN_ID=aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" \
           -e SKIP_SETCAP=true \
           --name vault -d -p 8200:8200 vault:0.10.0

SMSDB_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' vault)
cat << EOF > $CONFIG_FILE
{
    "cafile": "auth/selfsignedca.pem",
    "servercert": "auth/server.cert",
    "serverkey":  "auth/server.key",

    "smsdbaddress":     "http://$SMSDB_IP:8200",
    "vaulttoken":       "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
    "disable_tls": true
}
EOF

cat $CONFIG_FILE

docker run --workdir /sms -v $CONFIG_FILE:/sms/smsconfig.json \
           --name sms -d -p 10443:10443 nexus3.onap.org:10001/onap/aaf/sms

SMS_IP=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' sms)

echo "###### WAITING FOR ALL CONTAINERS TO COME UP"
sleep 20
for i in {1..20}; do
    curl -sS -m 1 http://${SMSDB_IP}:8200/v1/sys/seal-status && break
    echo sleep $i
    sleep $i
done

#
# add here all ROBOT_VARIABLES settings
#
echo "# sms robot variables settings";
ROBOT_VARIABLES="-v SMS_HOSTNAME:http://${SMS_IP} -v SMS_PORT:10443"

echo ${ROBOT_VARIABLES}
