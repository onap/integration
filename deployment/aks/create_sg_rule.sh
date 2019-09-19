#!/bin/bash
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

RESOURCE_GROUP=$1
SECURITY_GROUP=$2
DESTINATION_ADDRESS=$3
DESTINATION_PORT=$4
SOURCE_ADDRESS=$5
SOURCE_PORT=$6
PROTOCOL=$7
RULE_NAME=$8
PRIORITY=$9

az network nsg rule create --resource-group "$RESOURCE_GROUP" \
                           --nsg-name "$SECURITY_GROUP" \
                           --name "$RULE_NAME" \
                           --source-address-prefixes $SOURCE_ADDRESS \
                           --source-port-ranges "$SOURCE_PORT" \
                           --destination-address-prefixes "$DESTINATION_ADDRESS" \
                           --destination-port-ranges "$DESTINATION_PORT" \
                           --protocol "$PROTOCOL" \
                           --priority "$PRIORITY"
