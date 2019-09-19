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
NO_PROMPT=0
RANDOM_PREFIX="ONAP"
RANDOM_STRING="$RANDOM_PREFIX"-`cat /dev/urandom | env LC_CTYPE=C tr -cd 'a-zA-Z0-9' | head -c 4`


NFS_NAME=
NFS_RG=
NFS_VM_SIZE=
NFS_LOCATION=
SUBNET_CIDR=
ADMIN_USER=
BUILD_DIR=
NFS_VNET_NAME=
PUBLIC_KEY=
USER_PUBLIC_IP_PREFIX=
NFS_SUBNET_NAME=
AKS_POD_CIDR=
NFS_DISK_SIZE=

function check_required_parameter() {
  # arg1 = parameter
  # arg2 = parameter name
  if [ -z "$1" ]; then
    echo "$2 was not was provided. This parameter is required."
    exit 1
  fi
}

function check_optional_paramater() {
  # arg1 = parameter
  # arg2 = parameter name
  if [ -z "$1" ]; then
    echo "$2"
  else
    echo "$1"
  fi
}


while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "./create_nfs.sh [options]"
      echo " "
      echo " "
      echo "required:"
      echo "--public-key                public key to add for admin user [required]"
      echo "--user-public-ip            public ip that will be granted access to VM [required]"
      echo "-l, --location              location to deploy VM [required]"
      echo "-u, --admin-user            admin user to create on VM [required]"
      echo "--aks-node-cidr             CIDR for Kubernetes nodes [required]. This is used during the NFS deploy to grant access to the NFS server from Kubernetes."
      echo " "
      echo "additional options:"
      echo "-f, --no-prompt             executes with no prompt for confirmation"
      echo "-h, --help                  provide brief overview of script"
      echo "-n, --name                  VM name [optional]"
      echo "-g, --resource-group        resource group that will be created [optional]"
      echo "-s, --size                  Azure flavor size for VM [optional]"
      echo "-c, --cidr                  cidr for VNET to create for VM [optional]."
      echo "-d, --directory             directory to store cloud config data [optional]"
      echo "--vnet-name                 name of Vnet to create for VM [optional]"
      echo "--nfs-subnet-name           subnet name created on VNET [optional]"
      echo "--nfs-disk-size             size of external disk to be mounted on NFS VM [optional]"
      echo ""
      exit 0
      ;;
    -f|--no-prompt)
      shift
      NO_PROMPT=1
      ;;
    -n|--name)
      shift
      NFS_NAME=$1
      shift
      ;;
    -g|--resource-group)
      shift
      NFS_RG=$1
      shift
      ;;
    -s|--size)
      shift
      NFS_VM_SIZE=$1
      shift
      ;;
    -l|--location)
      shift
      NFS_LOCATION=$1
      shift
      ;;
    -c|--cidr)
      shift
      SUBNET_CIDR=$1
      shift
      ;;
    -u|--admin-user)
      shift
      ADMIN_USER=$1
      shift
      ;;
    -d|--directory)
      shift
      BUILD_DIR=$1
      shift
      ;;
    --vnet-name)
      shift
      NFS_VNET_NAME=$1
      shift
      ;;
    --public-key)
      shift
      PUBLIC_KEY=$1
      shift
      ;;
    --user-public-ip)
      shift
      USER_PUBLIC_IP_PREFIX=$1
      shift
      ;;
    --aks-node-cidr)
      shift
      AKS_POD_CIDR=$1
      shift
      ;;
    --nfs-subnet-name)
      shift
      NFS_SUBNET_NAME=$1
      shift
      ;;
    --nfs-disk-size)
      shift
      NFS_DISK_SIZE=$1
      shift
      ;;
    *)
      echo "Unknown Argument $1. Try running with --help."
      exit 0
      ;;
  esac
done

check_required_parameter "$ADMIN_USER" "--admin-user"
check_required_parameter "$PUBLIC_KEY" "--public-key"
check_required_parameter "$NFS_LOCATION" "--location"
check_required_parameter "$USER_PUBLIC_IP_PREFIX" "--user-public-ip"
check_required_parameter "$AKS_POD_CIDR" "--aks-node-cidr"

NFS_RG=$(check_optional_paramater "$NFS_RG" $RANDOM_STRING"-NFS-RG")
NFS_NAME=$(check_optional_paramater "$NFS_NAME" $RANDOM_STRING"-NFS")
NFS_VM_SIZE=$(check_optional_paramater "$NFS_VM_SIZE" "Standard_DS4_v2")
SUBNET_CIDR=$(check_optional_paramater "$SUBNET_CIDR" "174.0.0.0/24")
BUILD_DIR=$(check_optional_paramater "$BUILD_DIR" /tmp/nfs-$RANDOM_STRING)
NFS_VNET_NAME=$(check_optional_paramater "$NFS_VNET_NAME" $RANDOM_STRING"-NFS-VNET")
NFS_SUBNET_NAME=$(check_optional_paramater "$NFS_SUBNET_NAME" $RANDOM_STRING"-NFS-VNET-SUBNET")
NFS_DISK_SIZE=$(check_optional_paramater "$NFS_DISK_SIZE" "256")

if [ $NO_PROMPT = 0 ]; then
  read -p "Would you like to proceed? [y/n]" -n 1 -r
  echo " "
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
      exit 0
  fi
fi

set -x 
set -e 

NFS_IMAGE="UbuntuLTS"
NFS_SECURITY_GROUP=$NFS_NAME"-SG"
DATA_FILE=$BUILD_DIR/cloud-cfg.yaml

if [ ! -d $BUILD_DIR ]; then
  echo "running script standalone..."
  mkdir -p "$BUILD_DIR"
fi

$DIR/create_resource_group.sh "$NFS_RG" "$NFS_LOCATION"

cat > $DATA_FILE <<EOF
#cloud-config
package_upgrade: true
packages:
  - nfs-kernel-server
  - portmap
runcmd:
  - echo "/dockerdata-nfs $AKS_POD_CIDR(rw,async,no_root_squash,no_subtree_check)" >> /etc/exports
  - mkdir /dockerdata-nfs
  - chmod 777 -R /dockerdata-nfs
  - chown nobody:nogroup /dockerdata-nfs
  - exportfs -ra
  - systemctl restart nfs-kernel-server
EOF

az network nsg create --resource-group "$NFS_RG" \
                      --name "$NFS_SECURITY_GROUP"

$DIR/create_sg_rule.sh "$NFS_RG" "$NFS_SECURITY_GROUP" '*' "22" "$USER_PUBLIC_IP_PREFIX" '*' '*' "SSH" "100"

az vm create --name "$NFS_NAME" \
             --resource-group "$NFS_RG" \
             --size "$NFS_VM_SIZE" \
             --data-disk-sizes-gb "$NFS_DISK_SIZE" \
             --admin-username "$ADMIN_USER" \
             --ssh-key-value @"$PUBLIC_KEY" \
             --image "UbuntuLTS" \
             --location "$NFS_LOCATION" \
             --subnet-address-prefix "$SUBNET_CIDR" \
             --subnet "$NFS_SUBNET_NAME" \
             --vnet-address-prefix "$SUBNET_CIDR" \
             --vnet-name "$NFS_VNET_NAME" \
             --custom-data "$DATA_FILE" \
             --nsg "$NFS_SECURITY_GROUP"
echo ""

az network vnet subnet update --resource-group "$NFS_RG" \
                              --name "$NFS_SUBNET_NAME" \
                              --vnet-name "$NFS_VNET_NAME" \
                              --network-security-group "$NFS_SECURITY_GROUP"

