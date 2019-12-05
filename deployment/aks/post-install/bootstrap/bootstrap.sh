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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

set -x 

if [ ! -d $BUILD_DIR ]; then
  mkdir -p $BUILD_DIR
fi

# TODO 
# Get these from values.yaml
export AAI_DNS_NAME=aai.onap
export AAI_PORT=8443
export AAI_USER=AAI
export AAI_PASS=AAI
export AAI_PROTOCOL=https
export VID_DNS_NAME=vid.onap
export VID_PORT=8443
export VID_PROTOCOL=https
export SDC_DNS_NAME=sdc-fe.onap
export SDC_PORT=9443
export SDC_PROTOCOL=https

DATA_FILE=$BUILD_DIR"/get_tenant_id.json"

cat > $DATA_FILE <<EOF
{ "auth": {
    "identity": {
      "methods": ["password"],
      "password": {
        "user": {
          "name": "$OPENSTACK_USER",
          "domain": { "id": "default" },
          "password": "$OPENSTACK_PASS"
        }
      }
    },
    "scope": {
      "project": {
        "name": "$OPENSTACK_TENANT",
        "domain": { "id": "default" }
      }
    }
  }
}
EOF

http_code=""
COUNTER=0

until [ "$http_code" = "201" ] || [ $COUNTER -gt 360 ]; do
http_code=`curl -sL -w "%{http_code}" -o /dev/null -H "Content-Type: application/json" -d @"$DATA_FILE" "http://$OPENSTACK_IP/identity/v3/auth/tokens"`
echo ""
echo "http_code $http_code"
COUNTER=$((COUNTER +1))
sleep 10
done

TENANT_ID=`curl -s -H "Content-Type: application/json" -d @"$DATA_FILE" "http://$OPENSTACK_IP/identity/v3/auth/tokens" | jq --raw-output '.token.project.id'`

if [ $? -ne 0 ]; then
  echo "Failure getting tenant ID from openstack, exiting..."
  exit 1
fi

export TENANT_ID=$TENANT_ID

URI="aai/util/echo?action=long"
http_code=""
COUNTER=0

until [ "$http_code" = "200" ] || [ $COUNTER -gt 180 ]; do
echo "performing aai healthcheck..."
http_code=`curl -sL -w "%{http_code}" -o /dev/null -I --insecure -u $AAI_USER:$AAI_PASS -X GET "$AAI_PROTOCOL://$AAI_DNS_NAME:$AAI_PORT/$URI" \
  -H 'X-TransactionId: 9999' \
  -H 'X-FromAppId: jimmy-postman' \
  -H 'Real-Time: true' \
  -H 'Cache-Control: no-cache'`
COUNTER=$((COUNTER +1))
sleep 10
done

if [ "$http_code" != "200" ]; then
  echo "AAI Healthcheck unsuccessful :("
  echo "Something went wrong during the ONAP installation."
  exit 1
fi

echo "Creating CLLI $CLLI..."
$DIR/create_clli.sh

echo "Creating Cloud Region $CLOUD_REGION..."
$DIR/create_cloud_region.sh

echo "Creating Cloud Region Relationship..."
$DIR/create_cloud_region_relationship.sh

echo "Creating Cloud Customer $CUSTOMER..."
$DIR/create_customer.sh

echo "Creating Cloud Service Type $SERVICE_TYPE..."
$DIR/create_service_type.sh

echo "Creating Subscription..."
$DIR/create_subscription.sh

echo "Creating Subscription Relationship..."
$DIR/create_cloud_region_subscriber_relationship.sh

echo "Creating Availability Zone $AZ..."
$DIR/create_az.sh


URI="vid/healthCheck"
http_code=""
COUNTER=0

until [ "$http_code" = "200" ] || [ $COUNTER -gt 180 ]; do
echo "performing vid healthcheck..."
http_code=`curl -sL -w "%{http_code}" -o /dev/null --insecure -I -X GET "$VID_PROTOCOL://$VID_DNS_NAME:$VID_PORT/$URI"`
COUNTER=$((COUNTER +1))
sleep 10
done

if [ "$http_code" != "200" ]; then
  echo "VID Healthcheck unsuccessful :("
  echo "Something went wrong during the ONAP installation."
  exit 1
fi

echo "Creating Owning Entity $OE..."
$DIR/create_owning_entity.sh

echo "Creating Platform $PLATFORM..."
$DIR/create_platform.sh

echo "Creating Project $PROJECT..."
$DIR/create_project.sh

echo "Creating LOB $LOB..."
$DIR/create_lob.sh

echo "Creating Cloud Site..."
$DIR/create_cloud_site.sh

URI="sdc1/rest/healthCheck"
http_code=""
COUNTER=0

until [ "$http_code" = "200" ] || [ $COUNTER -gt 180 ]; do
echo "performing sdc healthcheck..."
http_code=`curl -k -sL -w "%{http_code}" -o /dev/null -I -X GET "$SDC_PROTOCOL://$SDC_DNS_NAME:$SDC_PORT/$URI"`
COUNTER=$((COUNTER +1))
sleep 10
done

if [ "$http_code" != "200" ]; then
  echo "SDC Healthcheck unsuccessful :("
  echo "Something went wrong during the ONAP installation."
  exit 1
fi

