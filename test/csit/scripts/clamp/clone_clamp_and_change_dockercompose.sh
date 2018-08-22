#!/bin/bash
#
# ============LICENSE_START=======================================================
# ONAP CLAMP
# ================================================================================
# Copyright (C) 2017 AT&T Intellectual Property. All rights
#                             reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
# ===================================================================
# ECOMP is a trademark and service mark of AT&T Intellectual Property.
#

echo "This is ${WORKSPACE}/test/csit/scripts/clamp/clone_clamp_and_change_dockercompose.sh"

firefox --version
which firefox


# Clone Clamp repo to get extra folder that has all needed to run docker with docker-compose to start DB and Clamp
mkdir -p $WORKSPACE/archives/clamp-clone
cd $WORKSPACE/archives/clamp-clone
git clone --depth 1 http://gerrit.onap.org/r/clamp -b master
cd clamp/extra/docker/clamp/

# Pull the Clamp docker image from nexus instead of local image by default in the docker-compose.yml
sed -i '/image: onap\/clamp/c\    image: nexus3.onap.org:10001\/onap\/clamp' docker-compose.yml

# Change config to take third_party_proxy:8085 for SDC, Policy and DCAE simulator
sed -i 's/}/,\"clamp.config.policy.pdpUrl1\":\"http:\/\/third_party_proxy:8085\/pdp\/ , testpdp, alpha123\",\"clamp.config.policy.pdpUrl2\":\"http:\/\/third_party_proxy:8085\/pdp\/ , testpdp, alpha123\",\"clamp.config.policy.papUrl\":\"http:\/\/third_party_proxy:8085\/pap\/ , testpap, alpha123\",\"clamp.config.policy.clientId\":\"python\",\"clamp.config.policy.clientKey\":\"dGVzdA==\",\"clamp.config.sdc.catalog.url\":\"http:\/\/third_party_proxy:8085\/sdc\/v1\/catalog\/\",\"clamp.config.sdc.hostUrl\":\"http:\/\/third_party_proxy:8085\",\"clamp.config.sdc.serviceUrl\":\"http:\/\/third_party_proxy:8085\/sdc\/v1\/catalog\/services\",\"clamp.config.dcae.inventory.url\":\"http:\/\/third_party_proxy:8085\",\"clamp.config.dcae.dispatcher.url\":\"http:\/\/third_party_proxy:8085\",\"spring.profiles.active\":\"clamp-default,clamp-default-user,clamp-sdc-controller\",\"server.ssl.client-auth\":\"want\"}/g' clamp.env

# Add the sql to create template so it is played by docker-compose later
cp ../../../src/test/resources/sql/four_templates_only.sql ../../sql/bulkload/
echo 'mysql -uroot -p$MYSQL_ROOT_PASSWORD -f < four_templates_only.sql' >> ../../sql/load-sql-files-tests-automation.sh
