#!/bin/bash
#
# Copyright 2017 ZTE Corporation.
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
# $1 nickname for the RuleMgt instance
# $2 IP address of JDBC

docker login -u docker -p docker nexus3.onap.org:10001

run-instance.sh nexus3.onap.org:10001/onap/aai/esr-server:latest $1 "-e MSB_ADDR=$3 -e MSB_PORT=$4 -p 9518:9518"
