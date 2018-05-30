#!/bin/bash
#
# Copyright 2017 AT&T Intellectual Property. All rights reserved.
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

response=$(curl --write-out '%{http_code}' --silent --output /dev/null http://portal.api.simpledemo.onap.org:8989/ONAPPORTAL/portalApi/healthCheck); echo $response

response=$(curl --write-out '%{http_code}' --silent   http://portal.api.simpledemo.onap.org:8989/ONAPPORTAL/login.htm); echo $response


cat portal/deliveries/$LOGS_DIR/onapportal/error.log
cat portal/deliveries/$LOGS_DIR/catalina.out
cat portal/deliveries/$LOGS_DIR/localhost.2018-06-19.log
cat portal/deliveries/$LOGS_DIR/localhost_access_log.2018-06-19.txt


docker kill $(docker ps -q)


