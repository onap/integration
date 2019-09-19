#!/bin/sh
# Copyright 2019 AT&T Intellectual Property. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -x 

SOURCE_VNET=$1
SOURCE_RESOURCE_GROUP=$2
REMOTE_VNET=$3
PEER_NAME=$4

az network vnet peering create --resource-group "$SOURCE_RESOURCE_GROUP" \
                               --name "$PEER_NAME" \
                               --vnet-name "$SOURCE_VNET" \
                               --remote-vnet "$REMOTE_VNET" \
                               --allow-vnet-access \
                               --allow-forwarded-traffic