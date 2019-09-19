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

DATA_FILE=$BUILD_DIR"/aai_subscription.json"

URI="aai/v11/business/customers/customer/$CUSTOMER/service-subscriptions/service-subscription/$SERVICE_TYPE"

cat > $DATA_FILE <<EOF
{
    "relationship-list":
        {
            "relationship":
                [
                    {
                    "related-to":"tenant",
                    "relationship-data":
                        [
                            {
                                "relationship-key":"cloud-region.cloud-owner",
                                "relationship-value":"$CLOUD_OWNER"
                            },
                            {
                                "relationship-key":"cloud-region.cloud-region-id",
                                "relationship-value":"$CLOUD_REGION"
                            },
                            {
                                "relationship-key":"tenant.tenant-id",
                                "relationship-value":"$TENANT_ID"
                            }
                        ]
                    }
                ]
        },
        "service-type":"$SERVICE_TYPE"
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
