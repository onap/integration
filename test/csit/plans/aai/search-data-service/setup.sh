#!/bin/bash
#
# Copyright © 2017 AT&T Intellectual Property.
# Copyright © 2017 Amdocs
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ECOMP is a trademark and service mark of AT&T Intellectual Property.

echo search service setup script running

export SEARCH_LOGS="/opt/aai/logroot/AAI-SEARCH";
export MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1);
export DOCKER_REGISTRY="nexus3.onap.org:10001";

# inject the current IP to the elastic-search config file
echo "es.ip-address="`ip addr show docker0 | head -3 | tail -1 | cut -d' ' -f6 | cut -d'/' -f1` >> appconfig/elastic-search.properties

docker run -d --name "stretchy" -p 9200:9200 -e "http.host=0.0.0.0" -e "transport.host=127.0.0.1" elasticsearch:2.4.6
docker-compose -f docker-compose.yml up -d aai.searchservice.simpledemo.openecomp.org

echo sleeping for 10 seconds while services start up
sleep 10
