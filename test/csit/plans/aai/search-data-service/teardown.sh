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


export SEARCH_LOGS="/opt/aai/logroot/AAI-SEARCH";
export MTU=$(/sbin/ifconfig | grep MTU | sed 's/.*MTU://' | sed 's/ .*//' | sort -n | head -1);
export DOCKER_REGISTRY="nexus3.onap.org:10001";

docker-compose -f docker-compose.yml stop
docker stop stretchy
docker-compose -f docker-compose.yml rm -f -v
docker rm stretchy

# remove the line we injected into the elastic-search config
sed -i '$ d' appconfig/elastic-search.properties
