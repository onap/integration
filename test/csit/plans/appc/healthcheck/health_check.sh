#!/usr/bin/env bash
###############################################################################
# Copyright 2018 AT&T
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
###############################################################################
SCRIPTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $SCRIPTS

response=$(curl --write-out '%{http_code}' --silent --output /dev/null -H "Authorization: Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==" -X POST -H "X-FromAppId: csit-appc" -H "X-TransactionId: csit-appc" -H "Accept: application/json" -H "Content-Type: application/json" http://localhost:8282/restconf/operations/SLI-API:healthcheck )

if [ "$response" == "200" ]; then
    echo "APPC health check passed."
    exit 0;
fi

echo "APPC health check failed with response code ${response}."
exit 1
