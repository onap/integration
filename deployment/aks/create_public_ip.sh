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

PUBLIC_IP_NAME=$1
PUBLIC_IP_RESOURCE_GROUP=$2
NIC_NAME=$3

az network public-ip create --name "$PUBLIC_IP_NAME" \
                            --resource-group "$PUBLIC_IP_RESOURCE_GROUP"

az network nic ip-config update --name "ipconfig1" \
                                --resource-group "$PUBLIC_IP_RESOURCE_GROUP" \
                                --nic-name "$NIC_NAME" \
                                --public-ip-address "$PUBLIC_IP_NAME"
