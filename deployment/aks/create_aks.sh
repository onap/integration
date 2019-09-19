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

AKS_NAME=
AKS_RESOURCE_GROUP_NAME=
AKS_K8_VERSION=
LOCATION=
AKS_NODE_COUNT=
AKS_NODE_SIZE=
AKS_SERVICE_CIDR=
AKS_POD_CIDR=
AKS_DNS_IP=
AKS_NODE_CIDR=
AKS_NETWORK_NAME=
USER_PUBLIC_IP_PREFIX=
PUBLIC_KEY=
AKS_ADMIN_USER=

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
  # arg2 = default
  if [ -z "$1" ]; then
    echo "$2"
  else
    echo "$1"
  fi
}


while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "./create_aks.sh [options]"
      echo " "
      echo " "
      echo "required:"
      echo "--user-public-ip            public ip that will be granted access to AKS [required]"
      echo "--admin-user                admin user created on AKS nodes [required]"
      echo "--public-key                public key added for admin user [required]"
      echo "-l, --location              location to deploy AKS [required]"
      echo " "
      echo "additional options:"
      echo "-f, --no-prompt             executes with no prompt for confirmation"
      echo "-h, --help                  provide brief overview of script"
      echo "-n, --name                  AKS name [optional]"
      echo "-g, --resource-group        name of resource group that will be created [optional]"
      echo "-s, --size                  azure flavor size for Kube nodes [optional]"
      echo "-v, --kube-version          version of Kubernetes for cluster [optional]"
      echo "-c, --node-count            number of nodes for cluster [optional]"
      echo "--service-cidr              cidr for Kuberenetes services [optional]."
      echo "--dns-ip                    IP for Kuberenetes dns service [optional]. This should be from --service-cidr."
      echo "--pod-cidr                  cidr for Kuberenetes pods [optional]."
      echo "--node-cidr                 cidr for Kuberenetes nodes [optional]."
      echo "--vnet-name                 name of Vnet to create for Kubernetes Cluster [optional]"
      echo ""
      exit 0
      ;;
    -f|--no-prompt)
      shift
      NO_PROMPT=1
      ;;
    -n|--name)
      shift
      AKS_NAME=$1
      shift
      ;;
    -g|--resource-group)
      shift
      AKS_RESOURCE_GROUP_NAME=$1
      shift
      ;;
    -s|--size)
      shift
      AKS_NODE_SIZE=$1
      shift
      ;;
    -l|--location)
      shift
      LOCATION=$1
      shift
      ;;
    -v|--kube-version)
      shift
      AKS_K8_VERSION=$1
      shift
      ;;
    -c|--node-count)
      shift
      AKS_NODE_COUNT=$1
      shift
      ;;
    --service-cidr)
      shift
      AKS_SERVICE_CIDR=$1
      shift
      ;;
    --dns-ip)
      shift
      AKS_DNS_IP=$1
      shift
      ;;
    --pod-cidr)
      shift
      AKS_POD_CIDR=$1
      shift
      ;;
    --node-cidr)
      shift
      AKS_NODE_CIDR=$1
      shift
      ;;
    --vnet-name)
      shift
      AKS_NETWORK_NAME=$1
      shift
      ;;
    --user-public-ip)
      shift
      USER_PUBLIC_IP_PREFIX=$1
      shift
      ;;
    --admin-user)
      shift
      AKS_ADMIN_USER=$1
      shift
      ;;
    --public-key)
      shift
      PUBLIC_KEY=$1
      shift
      ;;
    *)
      echo "Unknown Argument $1. Try running with --help."
      exit 0
      ;;
  esac
done

check_required_parameter "$LOCATION" "--location"
check_required_parameter "$USER_PUBLIC_IP_PREFIX" "--user-public-ip"
check_required_parameter "$AKS_ADMIN_USER" "--admin-user"
check_required_parameter "$PUBLIC_KEY" "--public-key"

AKS_RESOURCE_GROUP_NAME=$(check_optional_paramater "$AKS_RESOURCE_GROUP_NAME" $RANDOM_STRING"-AKSRG")
AKS_NAME=$(check_optional_paramater "$AKS_NAME" $RANDOM_STRING"-AKS")
AKS_NODE_SIZE=$(check_optional_paramater "$AKS_NODE_SIZE" "Standard_DS4_v2")
AKS_POD_CIDR=$(check_optional_paramater "$AKS_POD_CIDR" "168.1.0.0/16")
AKS_NODE_CIDR=$(check_optional_paramater "$AKS_NODE_CIDR" "169.1.0.0/16")
AKS_NETWORK_NAME=$(check_optional_paramater "$AKS_NETWORK_NAME" $RANDOM_STRING"-AKS-VNET")
AKS_SERVICE_CIDR=$(check_optional_paramater "$AKS_SERVICE_CIDR" "170.1.0.0/16")
AKS_DNS_IP=$(check_optional_paramater "$AKS_DNS_IP" "170.1.0.10")
AKS_K8_VERSION=$(check_optional_paramater "$AKS_K8_VERSION" "1.13.5")
AKS_NODE_COUNT=$(check_optional_paramater "$AKS_NODE_COUNT" "7")

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

AKS_SUBNET_NAME=$AKS_NETWORK_NAME"-SUBNET"

echo "Creating AKS Resource Group $AKS_RESOURCE_GROUP_NAME in $LOCATION"
$DIR/create_resource_group.sh "$AKS_RESOURCE_GROUP_NAME" "$LOCATION"

az network vnet create --resource-group "$AKS_RESOURCE_GROUP_NAME" \
                       --name "$AKS_NETWORK_NAME" \
                       --address-prefix "$AKS_NODE_CIDR" \
                       --subnet-name "$AKS_SUBNET_NAME" \
                       --subnet-prefix "$AKS_NODE_CIDR"

AKS_SUBNET_ID=`az network vnet show --resource-group ${AKS_RESOURCE_GROUP_NAME} --name ${AKS_NETWORK_NAME} --query "subnets | [0] | id" --output tsv`

az aks create --name "$AKS_NAME" \
              --resource-group "$AKS_RESOURCE_GROUP_NAME" \
              --disable-rbac \
              --kubernetes-version "$AKS_K8_VERSION" \
              --location "$LOCATION" \
              --node-count "$AKS_NODE_COUNT" \
              --node-vm-size "$AKS_NODE_SIZE" \
              --service-cidr "$AKS_SERVICE_CIDR" \
              --pod-cidr "$AKS_POD_CIDR" \
              --network-plugin "kubenet" \
              --dns-service-ip "$AKS_DNS_IP" \
              --admin-username "$AKS_ADMIN_USER" \
              --ssh-key-value "$PUBLIC_KEY" \
              --vnet-subnet-id "$AKS_SUBNET_ID"
echo ""

AKS_MANAGEMENT_RESOURCE_GROUP_NAME=`az group list --query "[?starts_with(name, 'MC_${AKS_RESOURCE_GROUP_NAME}')].name | [0]" --output tsv`
AKS_NSG_NAME=`az resource list --resource-group ${AKS_MANAGEMENT_RESOURCE_GROUP_NAME} --resource-type "Microsoft.Network/networkSecurityGroups" --query "[0] | name" --output tsv`
AKS_NSG_ID=`az resource list --resource-group ${AKS_MANAGEMENT_RESOURCE_GROUP_NAME} --resource-type "Microsoft.Network/networkSecurityGroups" --query "[0] | id" --output tsv`

echo "Associating Security Group with AKS Subnet ${AKS_SUBNET_NAME}"
az network vnet subnet update --resource-group="$AKS_RESOURCE_GROUP_NAME" \
                              --name "$AKS_SUBNET_NAME" \
                              --vnet-name "$AKS_NETWORK_NAME" \
                              --network-security-group "$AKS_NSG_ID"

for ((i=0;i<$AKS_NODE_COUNT;i++)); do
  NIC_NAME=`az resource list --resource-group ${AKS_MANAGEMENT_RESOURCE_GROUP_NAME} --resource-type "Microsoft.Network/networkInterfaces" --query "[$i] | name" --output tsv`
  echo "Associating Security Group ${AKS_NSG_NAME} with AKS Node NIC ${NIC_NAME}"
  az network nic update --resource-group "$AKS_MANAGEMENT_RESOURCE_GROUP_NAME" -n "$NIC_NAME" --network-security-group "$AKS_NSG_NAME"
  echo ""
done

