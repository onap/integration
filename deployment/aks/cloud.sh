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
NO_INSTALL=0
NO_VALIDATE=0
POST_INSTALL=0
OVERRIDE=0

OPENSTACK_CLI_POD="os-cli-0"

if [ ! -f $DIR/cloud.conf ]; then
  echo "cloud.conf not found, exiting..."
  exit 1
fi

. $DIR/cloud.conf

while test $# -gt 0; do
  case "$1" in
    -h|--help)
      echo "./cloud.sh [options]"
      echo " "
      echo " "
      echo "options:"
      echo "-f, --no-prompt           executes with no prompt for confirmation"
      echo "-n, --no-install          don't install ONAP"
      echo "-o, --override            create integration override for robot configuration"
      echo "-d, --no-validate         dont validate pre-reqs before executing deployment"
      echo "-p, --post-install        execute post-install scripts"
      echo "-h, --help                provide brief overview of script"
      echo " "
      echo "This script deploys a cloud environment in Azure."
      echo "It: "
      echo "- Uses Azure Kubernetes Service (AKS) to bootstrap a kubernetes cluster."
      echo "- Creates a VM with an external disk to be used as NFS storage."
      echo "- Creates a VM and installs DevStack, to be used with ONAP."
      echo "- Launches ONAP onto the AKS Cluster via OOM."
      echo "- Configures Networking, SSH Access, and Security Group Rules"
      echo ""
      exit 0
      ;;
    -f|--no-prompt)
      shift
      NO_PROMPT=1
      ;;
    -n|--no-install)
      shift
      NO_INSTALL=1
      ;;
    -o|--override)
      shift
      OVERRIDE=1
      ;;
    -d|--no-validate)
      shift
      NO_VALIDATE=1
      ;;
    -p|--post-install)
      shift
      POST_INSTALL=1
      ;;
    *)
      echo "Unknown Argument. Try running with --help ."
      exit 0
      ;;
  esac
done

if [ $NO_VALIDATE = 0 ]; then
  $DIR/pre_install.sh "$AKS_K8_VERSION" "$LOCATION"
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

cat <<EOF

Here are the parameters to be used in this build:

# GLOBAL PARAMS
LOCATION                = "$LOCATION"
USER_PUBLIC_IP_PREFIX   = "$USER_PUBLIC_IP_PREFIX"
BUILD_DIR               = "$BUILD_DIR"

# AKS PARAMS
AKS_RESOURCE_GROUP_NAME = "$AKS_RESOURCE_GROUP_NAME"
AKS_NAME                = "$AKS_NAME"
AKS_K8_VERSION          = "$AKS_K8_VERSION"
AKS_NODE_COUNT          = "$AKS_NODE_COUNT"
AKS_NODE_SIZE           = "$AKS_NODE_SIZE"
AKS_DNS_PREFIX          = "$AKS_DNS_PREFIX"
AKS_POD_CIDR            = "$AKS_POD_CIDR"
AKS_NODE_CIDR           = "$AKS_NODE_CIDR"
AKS_SERVICE_CIDR        = "$AKS_SERVICE_CIDR"
AKS_DNS_IP              = "$AKS_DNS_IP"
AKS_VNET_NAME           = "$AKS_VNET_NAME"
AKS_ADMIN_USER=         = "$AKS_ADMIN_USER"

# NFS PARAMS
NFS_NAME                = "$NFS_NAME"
NFS_RG                  = "$NFS_RG"
NFS_VM_SIZE             = "$NFS_VM_SIZE"
NFS_LOCATION            = "$NFS_LOCATION"
NFS_CIDR                = "$NFS_CIDR"
NFS_ADMIN_USER          = "$NFS_ADMIN_USER"
NFS_VNET_NAME           = "$NFS_VNET_NAME"
NFS_SUBNET_NAME         = "$NFS_SUBNET_NAME"
NFS_DISK_SIZE           = "$NFS_DISK_SIZE"

# DEVSTACK PARAMS
DEVSTACK_NAME           = "$DEVSTACK_NAME"
DEVSTACK_RG             = "$DEVSTACK_RG"
DEVSTACK_VM_SIZE        = "$DEVSTACK_VM_SIZE"
DEVSTACK_LOCATION       = "$DEVSTACK_LOCATION"
DEVSTACK_CIDR           = "$DEVSTACK_CIDR"
DEVSTACK_PRIVATE_IP     = "$DEVSTACK_PRIVATE_IP"
DEVSTACK_ADMIN_USER     = "$DEVSTACK_ADMIN_USER"
DEVSTACK_VNET_NAME      = "$DEVSTACK_VNET_NAME"
DEVSTACK_SUBNET_NAME    = "$DEVSTACK_SUBNET_NAME"
DEVSTACK_DISK_SIZE      = "$DEVSTACK_DISK_SIZE"
DEVSTACK_BRANCH         = "$DEVSTACK_BRANCH"
OPENSTACK_USER          = "$OPENSTACK_USER"
OPENSTACK_PASS          = "$OPENSTACK_PASS"
OPENSTACK_TENANT        = "$OPENSTACK_TENANT"
IMAGE_LIST              = "$IMAGE_LIST"

# ONAP PARAMS
CLLI                    = "$CLLI"
CLOUD_OWNER             = "$CLOUD_OWNER"
CLOUD_REGION            = "$CLOUD_REGION"
CUSTOMER                = "$CUSTOMER"
SUBSCRIBER              = "$SUBSCRIBER"
SERVICE_TYPE            = "$SERVICE_TYPE"
AZ                      = "$AZ"
OE                      = "$OE"
LOB                     = "$LOB"
PLATFORM                = "$PLATFORM"
OS_ID                   = "$OS_ID"
OS_TENANT_ROLE          = "$OS_TENANT_ROLE"
OS_KEYSTONE             = "$OS_KEYSTONE"
OPENSTACK_REGION        = "$OPENSTACK_REGION"
PROJECT                 = "$PROJECT"
OOM_BRANCH              = "$OOM_BRANCH"
CHART_VERSION           = "$CHART_VERSION"
OOM_OVERRIDES           = "$OOM_OVERRIDES"
DOCKER_REPOSITORY       = "$DOCKER_REPOSITORY"
MASTER_PASSWORD         = "$MASTER_PASSWORD"

EOF

if [ $NO_PROMPT = 0 ]; then
  read -p "Would you like to proceed? [y/n]" -n 1 -r
  echo " "
  if [[ ! $REPLY =~ ^[Yy]$ ]]
  then
      exit 0
  fi
fi

echo "Starting instantiation. This will take a little while..."
sleep 3

set -x
set -e

mkdir -p $BUILD_DIR

echo "#!/bin/bash" > $BUILD_DIR/clean.sh
echo "" >> $BUILD_DIR/clean.sh
chmod 755 $BUILD_DIR/clean.sh

ssh-keygen -t rsa -N "" -f $BUILD_DIR/id_rsa

PUBLIC_KEY=$BUILD_DIR/id_rsa.pub
PRIVATE_KEY=$BUILD_DIR/id_rsa


echo "az group delete --resource-group $DEVSTACK_RG --yes" >> $BUILD_DIR/clean.sh
echo "" >> $BUILD_DIR/clean.sh

echo "Creating DEVSTACK Server $DEVSTACK_NAME in $LOCATION"
$DIR/create_devstack.sh --name "$DEVSTACK_NAME" \
                        --resource-group "$DEVSTACK_RG" \
                        --size "$DEVSTACK_VM_SIZE" \
                        --location "$DEVSTACK_LOCATION" \
                        --cidr "$DEVSTACK_CIDR" \
                        --admin-user "$DEVSTACK_ADMIN_USER" \
                        --directory "$BUILD_DIR" \
                        --vnet-name "$DEVSTACK_VNET_NAME" \
                        --public-key "$PUBLIC_KEY" \
                        --user-public-ip "$USER_PUBLIC_IP_PREFIX" \
                        --devstack-private-ip "$DEVSTACK_PRIVATE_IP" \
                        --devstack-subnet-name "$DEVSTACK_SUBNET_NAME" \
                        --devstack-disk-size "$DEVSTACK_DISK_SIZE" \
                        --openstack-username "$OPENSTACK_USER" \
                        --openstack-password "$OPENSTACK_PASS" \
                        --openstack-tenant "$OPENSTACK_TENANT" \
                        --image-list "$IMAGE_LIST" \
                        --devstack-branch "$DEVSTACK_BRANCH" \
                        --no-prompt


echo "az group delete --resource-group $NFS_RG --yes" >> $BUILD_DIR/clean.sh
echo "" >> $BUILD_DIR/clean.sh

echo "Creating NFS Server $NFS_NAME in $LOCATION"
$DIR/create_nfs.sh --name "$NFS_NAME" \
                   --resource-group "$NFS_RG" \
                   --size "$NFS_VM_SIZE" \
                   --location "$NFS_LOCATION" \
                   --cidr "$NFS_CIDR" \
                   --admin-user "$NFS_ADMIN_USER" \
                   --directory "$BUILD_DIR" \
                   --vnet-name "$NFS_VNET_NAME" \
                   --public-key "$PUBLIC_KEY" \
                   --user-public-ip "$USER_PUBLIC_IP_PREFIX" \
                   --nfs-subnet-name "$NFS_SUBNET_NAME" \
                   --aks-node-cidr "$AKS_NODE_CIDR" \
                   --nfs-disk-size "$NFS_DISK_SIZE" \
                   --no-prompt


echo "az group delete --resource-group $AKS_RESOURCE_GROUP_NAME --yes" >> $BUILD_DIR/clean.sh
echo "" >> $BUILD_DIR/clean.sh

echo "Creating AKS $AKS_NAME in $LOCATION"
$DIR/create_aks.sh --name "$AKS_NAME" \
                   --resource-group "$AKS_RESOURCE_GROUP_NAME" \
                   --kube-version "$AKS_K8_VERSION" \
                   --location "$LOCATION" \
                   --node-count "$AKS_NODE_COUNT" \
                   --size "$AKS_NODE_SIZE" \
                   --service-cidr "$AKS_SERVICE_CIDR" \
                   --pod-cidr "$AKS_POD_CIDR" \
                   --dns-ip "$AKS_DNS_IP" \
                   --node-cidr "$AKS_NODE_CIDR" \
                   --vnet-name "$AKS_VNET_NAME" \
                   --user-public-ip "$USER_PUBLIC_IP_PREFIX" \
                   --public-key "$PUBLIC_KEY" \
                   --admin-user "$AKS_ADMIN_USER" \
                   --no-prompt


AKS_MANAGEMENT_RESOURCE_GROUP_NAME=`az group list --query "[?starts_with(name, 'MC_${AKS_RESOURCE_GROUP_NAME}')].name | [0]" --output tsv`
AKS_VNET_ID=`az network vnet show --resource-group ${AKS_RESOURCE_GROUP_NAME} --name ${AKS_VNET_NAME} --query 'id' --output tsv`
NFS_VNET_ID=`az network vnet show --name ${NFS_VNET_NAME}  --resource-group ${NFS_RG} --query "id" --output tsv`
DEVSTACK_VNET_ID=`az network vnet show --name ${DEVSTACK_VNET_NAME}  --resource-group ${DEVSTACK_RG} --query "id" --output tsv`
AKS_ROUTE_TABLE_NAME=`az resource list --resource-group ${AKS_MANAGEMENT_RESOURCE_GROUP_NAME} --resource-type "Microsoft.Network/routeTables" --query "[0] | name" --output tsv`
DEVSTACK_PRIVATE_IP=`az vm show --name ${DEVSTACK_NAME} --resource-group ${DEVSTACK_RG} -d  --query "privateIps" --output tsv`
NFS_PRIVATE_IP=`az vm show --name ${NFS_NAME} --resource-group ${NFS_RG} -d  --query "privateIps" --output tsv`
NFS_PUBLIC_IP=`az vm show --name ${NFS_NAME} --resource-group ${NFS_RG} -d  --query "publicIps" --output tsv`
DEVSTACK_PUBLIC_IP=`az vm show --name ${DEVSTACK_NAME} --resource-group ${DEVSTACK_RG} -d  --query "publicIps" --output tsv`

# adding public ip to  aks
NIC_NAME0=`az resource list --resource-group ${AKS_MANAGEMENT_RESOURCE_GROUP_NAME} --resource-type "Microsoft.Network/networkInterfaces" --query "[0] | name" --output tsv`
AKS_NSG_NAME=`az resource list --resource-group ${AKS_MANAGEMENT_RESOURCE_GROUP_NAME} --resource-type "Microsoft.Network/networkSecurityGroups" --query "[0] | name" --output tsv`
$DIR/create_public_ip.sh "AKSPUBLICIP1" "$AKS_MANAGEMENT_RESOURCE_GROUP_NAME" "$NIC_NAME0"
$DIR/create_sg_rule.sh "$AKS_MANAGEMENT_RESOURCE_GROUP_NAME" "$AKS_NSG_NAME" '*' "30000-32000" "$USER_PUBLIC_IP_PREFIX" '*' '*' "ONAP" "120"

AKS_PUBLIC_IP_ADDRESS=`az network public-ip show --resource-group ${AKS_MANAGEMENT_RESOURCE_GROUP_NAME} -n AKSPUBLICIP1 --query "ipAddress" --output tsv`

### Peering networks ###
# peering requires source = VNet NAME, destination = VNet ID

echo "creating peering from AKS Vnet to NFS Vnet..."
$DIR/create_peering.sh "$AKS_VNET_NAME" \
                       "$AKS_RESOURCE_GROUP_NAME" \
                       "$NFS_VNET_ID" \
                       "kube-to-nfs"

echo "creating peering from AKS Vnet to Devstack Vnet..."
$DIR/create_peering.sh "$AKS_VNET_NAME" \
                       "$AKS_RESOURCE_GROUP_NAME" \
                       "$DEVSTACK_VNET_ID" \
                       "kube-to-devstack"

echo "creating peering from NFS Vnet to AKS Vnet..."
$DIR/create_peering.sh "$NFS_VNET_NAME" \
                       "$NFS_RG" \
                       "$AKS_VNET_ID" \
                       "nfs-to-kube"

echo "creating peering from NFS Vnet to AKS Vnet..."
$DIR/create_peering.sh "$DEVSTACK_VNET_NAME" \
                       "$DEVSTACK_RG" \
                       "$AKS_VNET_ID" \
                       "devstack-to-kube"


### Adding next hop to kubernetes for devstack ###
echo "creating route from AKS Vnet to Devstack Vnet..."
$DIR/create_route.sh "$DEVSTACK_CIDR" \
                     "guestvms" \
                     "$AKS_MANAGEMENT_RESOURCE_GROUP_NAME" \
                     "$AKS_ROUTE_TABLE_NAME" \
                     "$DEVSTACK_PRIVATE_IP"



# TODO
# Lets find a better place for this
az aks get-credentials --resource-group "$AKS_RESOURCE_GROUP_NAME" \
                       --name "$AKS_NAME" \
                       --file "$BUILD_DIR"/"kubeconfig"

$DIR/configure_nfs_pod.sh "$PRIVATE_KEY" \
                          "$BUILD_DIR"/"kubeconfig" \
                          "$NFS_PRIVATE_IP" \
                          "$AKS_ADMIN_USER"

# TODO
# add this to post-install or post-configure phase
# to support adding multiple devstacks to same ONAP
cat > "$BUILD_DIR/openstack_rc" <<EOF
export OS_USERNAME="$OPENSTACK_USER"
export OS_PROJECT_NAME="$OPENSTACK_TENANT"
export OS_AUTH_URL="http://$DEVSTACK_PRIVATE_IP/identity"
export OS_PASSWORD="$OPENSTACK_PASS"
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_DOMAIN_ID=default
EOF

$DIR/util/create_openstack_cli.sh "$BUILD_DIR/kubeconfig" \
                                  "$BUILD_DIR/openstack_rc" \
                                  "$OPENSTACK_CLI_POD"


if [ $OVERRIDE = 1 ]; then

$DIR/util/create_integration_override.sh "$BUILD_DIR" \
                                         "$OPENSTACK_CLI_POD" \
                                         "$BUILD_DIR/openstack_rc" \
                                         "$DOCKER_REPOSITORY" \
                                         "$NFS_PRIVATE_IP" \
                                         "$AKS_PUBLIC_IP_ADDRESS" \
                                         "$BUILD_DIR/kubeconfig" \
                                         "$MASTER_PASSWORD"

fi


if [ $NO_INSTALL = 0 ]; then

### Starting OOM install ###
echo "Installing ONAP..."
$DIR/create_onap.sh "$BUILD" \
                    "$BUILD_DIR/kubeconfig" \
                    "$OOM_BRANCH" \
                    "$BUILD_DIR" \
                    "$CHART_VERSION" \
                    "$OOM_OVERRIDES" \
                    "$MASTER_PASSWORD"

fi


set +x

cat > "$BUILD_DIR/deployment.notes" <<EOF
==================================================================
Phew, all done (yay!). ONAP and DevStack might still be installing
but here are the access details...

--------DEVSTACK ACCESS--------
ssh -i ${PRIVATE_KEY} ${DEVSTACK_ADMIN_USER}@${DEVSTACK_PUBLIC_IP}
horizon: http://${DEVSTACK_PUBLIC_IP}
cli: kubectl exec $OPENSTACK_CLI_POD -- sh -lc "<openstack command>"

--------NFS ACCESS--------
ssh -i ${PRIVATE_KEY} ${NFS_ADMIN_USER}@${NFS_PUBLIC_IP}

--------KUBERNETES ACCESS--------
kubeconfig: export KUBECONFIG=$BUILD_DIR/kubeconfig
dashboard: az aks browse --resource-group ${AKS_RESOURCE_GROUP_NAME} --name ${AKS_NAME}

--------BUILD DETAILS--------
Build directory: $BUILD_DIR
Integration repo: $BUILD_DIR/integration
OOM repo: $BUILD_DIR/oom

--------ADD TO /etc/hosts--------
$AKS_PUBLIC_IP_ADDRESS portal.api.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS sdc.api.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS sdc.api.fe.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS sdc.api.be.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS vid.api.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS policy.api.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS aai.api.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS cli.api.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS so.api.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS so.monitoring.api.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS so-monitoring
$AKS_PUBLIC_IP_ADDRESS sdnc.api.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS clamp.api.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS dcae.api.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS appc.api.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS aaf.api.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS portal-sdk.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS robot.api.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS msb.api.discovery.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS msb.api.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS aai.ui.simpledemo.onap.org
$AKS_PUBLIC_IP_ADDRESS policy.api.simpledemo.onap.org

EOF

cat "$BUILD_DIR/deployment.notes"


if [ $POST_INSTALL = 1 ]; then

echo "Executing post installation scripts..."
sleep 3

cat > "$BUILD_DIR/onap.conf" <<EOF
export CLLI=$CLLI
export CLOUD_OWNER=$CLOUD_OWNER
export CLOUD_REGION=$CLOUD_REGION
export OPENSTACK_IP=$DEVSTACK_PRIVATE_IP
export OPENSTACK_USER=$OPENSTACK_USER
export OPENSTACK_PASS=$OPENSTACK_PASS
export OPENSTACK_TENANT=$OPENSTACK_TENANT
export OPENSTACK_REGION=$OPENSTACK_REGION
export CUSTOMER=$CUSTOMER
export SUBSCRIBER=$SUBSCRIBER
export SERVICE_TYPE=$SERVICE_TYPE
export AZ=$AZ
export OE=$OE
export LOB=$LOB
export PLATFORM=$PLATFORM
export PROJECT=$PROJECT
export OS_ID=$OS_ID
export OS_TENANT_ROLE=$OS_TENANT_ROLE
export OS_KEYSTONE=$OS_KEYSTONE
export KUBECONFIG=$BUILD_DIR/kubeconfig
export NFS_PRIVATE_IP=$NFS_PRIVATE_IP
export DEVSTACK_PRIVATE_IP=$DEVSTACK_PRIVATE_IP
export PRIVATE_KEY=$PRIVATE_KEY
EOF

$DIR/post_install.sh "$BUILD_DIR/onap.conf" "$DIR/cloud.conf"

fi
