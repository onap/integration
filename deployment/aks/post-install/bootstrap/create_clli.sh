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

if [ -z $AAI_DNS_NAME ] || [ -z $AAI_PORT ]; then
  echo "AAI_DNS_NAME or AAI_PORT not found. These should be environment variables."
  exit 1
fi

DATA_FILE=$BUILD_DIR"/aai_ccli.json"

URI="aai/v11/cloud-infrastructure/complexes/complex/$CLLI"

# TODO 
# Parameterize the rest of the values in data, like physical location

cat > $DATA_FILE <<EOF
{
    "physical-location-id": "$CLLI",
    "data-center-code": "example-data-center-code-val-6667",
    "complex-name": "$CLLI",
    "identity-url": "example-identity-url-val-28399",
    "physical-location-type": "example-physical-location-type-val-28399",
    "street1": "example-street1-val-28399",
    "street2": "example-street2-val-28399",
    "city": "example-city-val-28399",
    "state": "example-state-val-28399",
    "postal-code": "example-postal-code-val-28399",
    "country": "example-country-val-28399",
    "region": "example-region-val-28399",
    "latitude": "1111",
    "longitude": "2222",
    "elevation": "example-elevation-val-28399",
    "lata": "example-lata-val-28399"
}
EOF

curl -i --insecure -u $AAI_USER:$AAI_PASS -X PUT "$AAI_PROTOCOL://$AAI_DNS_NAME:$AAI_PORT/$URI" \
  -H 'X-TransactionId: 9999' \
  -H 'X-FromAppId: jimmy-postman' \
  -H 'Real-Time: true' \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -H 'Cache-Control: no-cache' \
  -d @"$DATA_FILE"
echo ""