#!/bin/bash
# ========================================================================
# Copyright (c) 2018 Orange
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
# ========================================================================

$NEXUS_USERNAME=docker
$NEXUS_PASSWD=docker
$NEXUS_DOCKER_REPO=nexus3.onap.org:10001
$DOCKER_IMAGE_VERSION=latest

echo "This is ${WORKSPACE}/test/csit/scripts/externalapi-nbi/delete_nbi_containers.sh"

# Create directory
mkdir -p $WORKSPACE/externalapi-nbi
cd $WORKSPACE/externalapi-nbi

# Remove containers
docker-compose down
