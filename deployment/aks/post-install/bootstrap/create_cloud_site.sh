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

pushd .

cd /tmp

git clone http://gerrit.onap.org/r/integration /tmp/integration-repo
git clone https://github.com/onap/oom.git /tmp/oom-repo

cd /tmp/integration-repo/deployment/heat/onap-rke/scripts
SO_ENCRYPTION_KEY=`cat /tmp/oom-repo/kubernetes/so/resources/config/mso/encryption.key`
javac Crypto.java
SO_ENCRYPTED_KEY=`java Crypto "$OPENSTACK_PASS" "$SO_ENCRYPTION_KEY"`

popd

echo $SO_ENCRYPTED_KEY

MARIADBPOD_STATUS=`kubectl -n onap get pods | grep mariadb-galera | head -1 | awk '{print $3}'`
COUNTER=0

until [ "$MARIADBPOD_STATUS" = "Running" ] || [ $COUNTER -gt 120 ]; do
echo "mariadb pod not ready..."
COUNTER=$((COUNTER +1))
sleep 10
done

MARIADBPOD=`kubectl -n onap get pods | grep mariadb-galera | head -1 | awk '{print $1}'`
MARIADBSECRET=`kubectl -n onap get secrets | grep mariadb-galera-db-root-password | head -1 | awk '{print $1}'`
MARIADBPASSWORD=`kubectl -n onap get secret $MARIADBSECRET -o jsonpath="{.data.password}" | base64 -d`

COMMAND="INSERT INTO identity_services (id, identity_url, mso_id, mso_pass, admin_tenant, member_role, tenant_metadata, identity_server_type, identity_authentication_type, project_domain_name, user_domain_name) VALUES (\"$OS_ID\", \"http://$OPENSTACK_IP/identity/v3\", \"$OPENSTACK_USER\", \"$SO_ENCRYPTED_KEY\", \"$OPENSTACK_TENANT\", \"$OS_TENANT_ROLE\", 0, \"$OS_KEYSTONE\", \"USERNAME_PASSWORD\", \"default\", \"default\");"
kubectl -n onap exec -it $MARIADBPOD -- bash -c "mysql -u root --password='$MARIADBPASSWORD' --database=catalogdb --execute='$COMMAND'"

COMMAND="INSERT INTO cloud_sites (id, region_id, identity_service_id, cloud_version, clli) VALUES (\"$CLOUD_REGION\", \"$OPENSTACK_REGION\", \"$OS_ID\", \"2.5\", \"$CLOUD_REGION\");"
kubectl -n onap exec -it $MARIADBPOD -- bash -c "mysql -u root --password='$MARIADBPASSWORD' --database=catalogdb --execute='$COMMAND'"

