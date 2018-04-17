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

echo "This is ${WORKSPACE}/test/csit/scripts/externalapi-nbi/delete_nbi_containers.sh"

# Check if docker-compose file exists
if [ ! -f "$WORKSPACE/externalapi-nbi/docker-compose.yml" ]; then
    echo 'There is nothing to clean. Exiting...' >&2
    exit 0
fi

cd $WORKSPACE/externalapi-nbi

# Remove containers and attached/anonymous volume(s)
docker-compose down -v
# Force stop & remove all containers and volumes
docker-compose rm -f -s -v

# clean up
rm -rf $WORKSPACE/externalapi-nbi