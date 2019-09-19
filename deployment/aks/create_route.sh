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

ROUTE_PREFIX=$1
ROUTE_NAME=$2
RESOURCE_GROUP=$3
ROUTE_TABLE=$4
IP_ADDRESS=$5

az network route-table route create --address-prefix "$ROUTE_PREFIX" \
                                    --name "$ROUTE_NAME" \
                                    --next-hop-type "VirtualAppliance" \
                                    --resource-group "$RESOURCE_GROUP" \
                                    --route-table-name "$ROUTE_TABLE" \
                                    --next-hop-ip-address "$IP_ADDRESS"
echo ""