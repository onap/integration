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

OPENSTACK_RC=$1
OPENSTACK_PARAM=$2
BUILD_DIR=$3
INTEGRATION_TEMPLATE=$4
MASTER_PASSWORD=$5

if [ "$OPENSTACK_RC" == "" ] 
       then
        echo "No OPENSTACK_RC file"
        echo "Usage: create-robot-config.sh <openstack.rc>  <openstack_env_param>"
  exit
fi 
if [ "$OPENSTACK_PARAM" == "" ] 
        then
        echo "No OPENSTACK_PARAM"
        echo "Usage: create-robot-config.sh <openstack.rc>  <openstack_env_param>"
  exit
fi

source $OPENSTACK_RC
source $OPENSTACK_PARAM

env

SO_ENCRYPTION_KEY=aa3871669d893c7fb8abbcda31b88b4f
export OS_PASSWORD_ENCRYPTED_FOR_ROBOT=$(echo -n "$OS_PASSWORD" | openssl aes-128-ecb -e -K "$SO_ENCRYPTION_KEY" -nosalt | xxd -c 256 -p)

#Use new encryption method
pushd .

cd $BUILD_DIR/integration/deployment/heat/onap-rke/scripts
javac Crypto.java
SO_ENCRYPTION_KEY=aa3871669d893c7fb8abbcda31b88b4f
export OS_PASSWORD_ENCRYPTED=$(java Crypto "$OS_PASSWORD" "$SO_ENCRYPTION_KEY")

cp $INTEGRATION_TEMPLATE ./integration-override.yaml
template="integration-override.yaml"
sed -ir -e "s/\${OS_PASSWORD_ENCRYPTED_FOR_ROBOT}/$OS_PASSWORD_ENCRYPTED_FOR_ROBOT/"  $template
sed -ir -e "s/\${OS_PASSWORD_ENCRYPTED}/$OS_PASSWORD_ENCRYPTED/"  $template

sed -ir -e "s/\${OS_PROJECT_ID}/$OS_PROJECT_ID/"  $template
sed -ir -e "s/\${OS_USERNAME}/$OS_USERNAME/"  $template
sed -ir -e "s/\${OS_USER_DOMAIN_NAME}/$OS_USER_DOMAIN_NAME/"  $template
sed -ir -e "s/\${OS_PROJECT_NAME}/$OS_PROJECT_NAME/"  $template
sed -ir -e "s/\${OS_USERNAME}/$OS_USERNAME/"  $template
sed -ir -e "s~\${OS_AUTH_URL}~$OS_AUTH_URL~"  $template


sed -ir -e "s/__docker_proxy__/$DOCKER_REPOSITORY/"  $template
sed -ir -e "s/__public_net_id__/$OS_PUBLIC_NETWORK_ID/"  $template
sed -ir -e "s~__oam_network_cidr__~$OS_OAM_NETWORK_CIDR~"  $template
sed -ir -e "s/__oam_network_prefix__/$OS_OAM_NETWORK_PREFIX/"  $template
sed -ir -e "s/__oam_network_id__/$OS_OAM_NETWORK_ID/"  $template
sed -ir -e "s/__oam_subnet_id__/$OS_OAM_NETWORK_SUBNET_ID/"  $template
sed -ir -e "s/__sec_group__/$OS_SEC_GROUP/"  $template

sed -ir -e "s/\${OS_UBUNTU_14_IMAGE}/$OS_UBUNTU_14_IMAGE/"  $template
sed -ir -e "s/\${OS_UBUNTU_16_IMAGE}/$OS_UBUNTU_16_IMAGE/"  $template

sed -ir -e "s/\${MASTER_PASSWORD}/$MASTER_PASSWORD/"  $template

sed -ir -e "s/__nfs_ip_addr__/$NFS_IP_ADDR/"  $template
sed -ir -e "s/__k8s_01_vm_ip__/$K8S_01_VM_IP/"  $template

cat $template
cp $template  $BUILD_DIR/$template

popd
