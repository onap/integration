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

BUILD_DIR=$1
OPENSTACK_CLI_POD=$2
OPENSTACK_RC=$3
DOCKER_REPOSITORY=$4
NFS_IP_ADDR=$5
K8S_01_VM_IP=$6
KUBECONFIG=$7
MASTER_PASSWORD=$8

. $OPENSTACK_RC

export KUBECONFIG=$KUBECONFIG

git clone https://gerrit.onap.org/r/integration "$BUILD_DIR/integration"

echo ""
echo "Looping until openstack is ready."
echo "This can take a bit of time, and you might see errors initially if openstack is still launching."
echo ""
echo ""
# Need to wait until openstack is up and running
COUNTER=0
kubectl exec $OPENSTACK_CLI_POD -- sh -lc "openstack token issue"
until [ $? -eq 0 ] || [ $COUNTER -gt 60 ]; do
COUNTER=$((COUNTER +1))
sleep 60
echo "issuing auth token to openstack to verify openstack cli is up and running."
kubectl exec $OPENSTACK_CLI_POD -- sh -lc "openstack token issue"
done

if [ $? -ne 0 ]; then
  echo "Unable to communicate with openstack to create the integration-override.yaml file"
  exit 1
fi

OS_PUBLIC_NETWORK_ID=`kubectl exec $OPENSTACK_CLI_POD -- sh -lc "openstack network show public -c id -f value"`
OS_OAM_NETWORK_ID=`kubectl exec $OPENSTACK_CLI_POD -- sh -lc "openstack network show private -c id -f value"`
OS_OAM_NETWORK_SUBNET_ID=`kubectl exec $OPENSTACK_CLI_POD -- sh -lc "openstack subnet show private-subnet -c id -f value"`
OS_SEC_GROUP=`kubectl exec $OPENSTACK_CLI_POD -- sh -lc "openstack security group list --project $OS_PROJECT_NAME -c ID -f value"`
OS_OAM_NETWORK_CIDR=`kubectl exec $OPENSTACK_CLI_POD -- sh -lc "openstack subnet show public-subnet -c cidr -f value"`
OS_OAM_NETWORK_PREFIX=`echo $OS_OAM_NETWORK_CIDR | cut -d '.' -f1-2`

echo "export OS_PUBLIC_NETWORK_ID=$OS_PUBLIC_NETWORK_ID" > "$BUILD_DIR/openstack_params.conf"
echo "export DOCKER_REPOSITORY=$DOCKER_REPOSITORY" >> "$BUILD_DIR/openstack_params.conf"
echo "export OS_OAM_NETWORK_ID=$OS_OAM_NETWORK_ID" >> "$BUILD_DIR/openstack_params.conf"
echo "export OS_OAM_NETWORK_SUBNET_ID=$OS_OAM_NETWORK_SUBNET_ID" >> "$BUILD_DIR/openstack_params.conf"
echo "export OS_OAM_NETWORK_PREFIX=$OS_OAM_NETWORK_PREFIX" >> "$BUILD_DIR/openstack_params.conf"
echo "export OS_SEC_GROUP=$OS_SEC_GROUP" >> "$BUILD_DIR/openstack_params.conf"
echo "export OS_UBUNTU_14_IMAGE=trusty-server-cloudimg-amd64-disk1" >> "$BUILD_DIR/openstack_params.conf"
echo "export OS_UBUNTU_16_IMAGE=xenial-server-cloudimg-amd64-disk1" >> "$BUILD_DIR/openstack_params.conf"
echo "export OS_OAM_NETWORK_CIDR=$OS_OAM_NETWORK_CIDR" >> "$BUILD_DIR/openstack_params.conf"
echo "export NFS_IP_ADDR=$NFS_IP_ADDR" >> "$BUILD_DIR/openstack_params.conf"
echo "export K8S_01_VM_IP=$K8S_01_VM_IP" >> "$BUILD_DIR/openstack_params.conf"

OS_PROJECT_ID=`kubectl exec $OPENSTACK_CLI_POD -- sh -lc "openstack project show $OS_PROJECT_NAME -c id -f value"`

echo "export OS_PROJECT_ID=$OS_PROJECT_ID" >> "$OPENSTACK_RC"

$DIR/create_robot_config.sh "$OPENSTACK_RC" "$BUILD_DIR/openstack_params.conf" "$BUILD_DIR" "$DIR/integration_override.template" "$MASTER_PASSWORD"
