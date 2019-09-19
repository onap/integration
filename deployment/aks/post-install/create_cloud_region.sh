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

DATA_FILE=$BUILD_DIR"/aai_cloudregion.json"

URI="aai/v11/cloud-infrastructure/cloud-regions/cloud-region/$CLOUD_OWNER/$CLOUD_REGION"

cat > $DATA_FILE <<EOF
{
    "cloud-owner": "$CLOUD_OWNER",
    "cloud-region-id": "$CLOUD_REGION",
    "cloud-type": "openstack",
    "owner-defined-type": "t1",
    "cloud-region-version": "ocata",
    "cloud-zone": "z1",
    "complex-name": "$CLLI",
    "identity-url": "http://$OPENSTACK_IP/identity",
    "sriov-automation": false,
    "cloud-extra-info": "",
    "tenants": {
        "tenant": [
            {
                "tenant-id": "$TENANT_ID",
                "tenant-name": "$OPENSTACK_TENANT"
            }
        ]
    },
    "esr-system-info-list":
    {       
        "esr-system-info":
        [
            {
                "esr-system-info-id": "example-system-name-val-92940",
                "service-url": "http://$OPENSTACK_IP/identity",
                "user-name": "$OPENSTACK_USER",
                "password": "$OPENSTACK_PASS",
                "system-type": "VIM",
                "ssl-cacert": "",
                "ssl-insecure": true,
                "cloud-domain": "Default",
                "default-tenant": "$OPENSTACK_TENANT"
            }
        ]
    }
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
