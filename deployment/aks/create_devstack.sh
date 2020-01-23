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

DEVSTACK_RG=
DEVSTACK_LOCATION=
PUBLIC_KEY=
DEVSTACK_NAME=
DEVSTACK_VM_SIZE=
SUBNET_CIDR=
ADMIN_USER=
BUILD_DIR=
DEVSTACK_VNET_NAME=
USER_PUBLIC_IP_PREFIX=
DEVSTACK_PRIVATE_IP=
DEVSTACK_SUBNET_NAME=
DEVSTACK_DISK_SIZE=
OPENSTACK_USER=
OPENSTACK_PASS=
OS_PROJECT_NAME=
IMAGE_LIST=

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
      echo "./create_devstack.sh [options]"
      echo " "
      echo " "
      echo "required:"
      echo "--public-key                public key to add for admin user [required]"
      echo "--user-public-ip            public ip that will be granted access to VM [required]"
      echo "-l, --location              location to deploy VM [required]"
      echo "-u, --admin-user            admin user to create on VM [required]"
      echo " "
      echo "additional options:"
      echo "-f, --no-prompt             executes with no prompt for confirmation"
      echo "-h, --help                  provide brief overview of script"
      echo "-n, --name                  VM name [optional]"
      echo "-g, --resource-group        provide brief overview of script [optional]"
      echo "-s, --size                  Azure flavor size for VM [optional]"
      echo "-c, --cidr                  cidr for VNET to create for VM [optional]. If provided, must also provide --devstack-private-ip from same range."
      echo "-d, --directory             directory to store cloud config data [optional]"
      echo "--vnet-name                 name of Vnet to create for VM [optional]"
      echo "--image-list                space delimited list of image urls that will be added to devstack [optional]"
      echo "--devstack-private-ip       private ip assigned to VM [optional]. If provided, this value must come from the CIDR range of VNET."
      echo "--devstack-subnet-name      subnet name created on VNET [optional]"
      echo "--devstack-disk-size        size of OS disk to be allocated [optional]"
      echo "--openstack-username        default user name for openstack [optional]"
      echo "--openstack-password        default password for openstack [optional]"
      echo "--openstack-tenant          default tenant name for openstack [optional]"
      echo ""
      exit 0
      ;;
    -f|--no-prompt)
      shift
      NO_PROMPT=1
      ;;
    -n|--name)
      shift
      DEVSTACK_NAME=$1
      shift
      ;;
    -g|--resource-group)
      shift
      DEVSTACK_RG=$1
      shift
      ;;
    -s|--size)
      shift
      DEVSTACK_VM_SIZE=$1
      shift
      ;;
    -l|--location)
      shift
      DEVSTACK_LOCATION=$1
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
      DEVSTACK_VNET_NAME=$1
      shift
      ;;
    --image-list)
      shift
      IMAGE_LIST=$1
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
    --devstack-private-ip)
      shift
      DEVSTACK_PRIVATE_IP=$1
      shift
      ;;
    --devstack-subnet-name)
      shift
      DEVSTACK_SUBNET_NAME=$1
      shift
      ;;
    --devstack-disk-size)
      shift
      DEVSTACK_DISK_SIZE=$1
      shift
      ;;
    --openstack-username)
      shift
      OPENSTACK_USER=$1
      shift
      ;;
    --openstack-password)
      shift
      OPENSTACK_PASS=$1
      shift
      ;;
    --openstack-tenant)
      shift
      OS_PROJECT_NAME=$1
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
check_required_parameter "$DEVSTACK_LOCATION" "--location"
check_required_parameter "$USER_PUBLIC_IP_PREFIX" "--user-public-ip"

DEVSTACK_RG=$(check_optional_paramater "$DEVSTACK_RG" $RANDOM_STRING"-DEVSTACKRG")
DEVSTACK_NAME=$(check_optional_paramater "$DEVSTACK_NAME" $RANDOM_STRING"-DEVSTACK")
DEVSTACK_VM_SIZE=$(check_optional_paramater "$DEVSTACK_VM_SIZE" "Standard_DS4_v2")
SUBNET_CIDR=$(check_optional_paramater "$SUBNET_CIDR" "173.0.0.0/24")
BUILD_DIR=$(check_optional_paramater "$BUILD_DIR" /tmp/devstack-$RANDOM_STRING)
DEVSTACK_VNET_NAME=$(check_optional_paramater "$DEVSTACK_VNET_NAME" $RANDOM_STRING"-DEVSTACK-VNET")
DEVSTACK_PRIVATE_IP=$(check_optional_paramater "$DEVSTACK_PRIVATE_IP" "173.0.0.4")
DEVSTACK_SUBNET_NAME=$(check_optional_paramater "$DEVSTACK_SUBNET_NAME" $RANDOM_STRING"-DEVSTACK-VNET-SUBNET")
DEVSTACK_DISK_SIZE=$(check_optional_paramater "$DEVSTACK_DISK_SIZE" "64")
OPENSTACK_USER=$(check_optional_paramater "$OPENSTACK_USER" "admin")
OPENSTACK_PASS=$(check_optional_paramater "$OPENSTACK_PASS" "secret")
OS_PROJECT_NAME=$(check_optional_paramater "$OS_PROJECT_NAME" "admin")
IMAGE_LIST=$(check_optional_paramater "$IMAGE_LIST" "")


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

# TODO
# This needs to be hardened
DEVSTACK_PRIVATE_GATEWAY=`echo $DEVSTACK_PRIVATE_IP | sed  's/.$/1/'`
DEVSTACK_ALLOCATION_START=`echo $DEVSTACK_PRIVATE_IP | sed  's/.$/10/'`
DEVSTACK_ALLOCATION_END=`echo $DEVSTACK_PRIVATE_IP | sed  's/.$/240/'`

DATA_FILE=$BUILD_DIR/cloud-cfg-os.yaml

if [ ! -d $BUILD_DIR ]; then
  echo "running script standalone..."
  mkdir -p "$BUILD_DIR"
fi

$DIR/create_resource_group.sh "$DEVSTACK_RG" "$DEVSTACK_LOCATION"

az network public-ip create --resource-group "$DEVSTACK_RG" --name "DEVSTACK_PUBLIC_IP" --allocation-method Static
DEVSTACK_PUBLIC_IP=`az network public-ip show --resource-group "$DEVSTACK_RG" --name "DEVSTACK_PUBLIC_IP" --query 'ipAddress' --output tsv`

cat > $DATA_FILE <<EOF
#cloud-config
package_upgrade: true
packages:
  - resolvconf
  - python3-dev
users:
  - default
  - name: stack
    lock_passwd: False
    sudo: ["ALL=(ALL) NOPASSWD:ALL\nDefaults:stack !requiretty"]
    shell: /bin/bash
write_files:
  - path: /home/stack/start.sh
    permissions: 0755
    content: |
      #!/bin/sh
      DEBIAN_FRONTEND=noninteractive sudo apt-get -qqy update || sudo yum update -qy
      DEBIAN_FRONTEND=noninteractive sudo apt-get install -qqy git || sudo yum install -qy git
      sudo chown stack:stack /home/stack
      cd /home/stack
      git clone https://git.openstack.org/openstack-dev/devstack
      cd devstack
      cat > local.conf <<EOF
      [[local|localrc]]
      HOST_IP=$DEVSTACK_PRIVATE_IP
      SERVICE_HOST=$DEVSTACK_PRIVATE_IP
      MYSQL_HOST=$DEVSTACK_PRIVATE_IP
      RABBIT_HOST=$DEVSTACK_PRIVATE_IP
      GLANCE_HOSTPORT=$DEVSTACK_PRIVATE_IP:9292

      ADMIN_PASSWORD="secret"
      DATABASE_PASSWORD="secret"
      RABBIT_PASSWORD="secret"
      SERVICE_PASSWORD="secret"

      enable_service h-eng h-api h-api-cfn h-api-cw
      disable_service tempest

      enable_plugin heat https://git.openstack.org/openstack/heat
      enable_plugin heat-dashboard https://opendev.org/openstack/heat-dashboard

      ## Neutron options
      Q_USE_SECGROUP=True
      FLOATING_RANGE="$SUBNET_CIDR"
      IPV4_ADDRS_SAFE_TO_USE="192.168.100.0/24"
      Q_FLOATING_ALLOCATION_POOL=start=$DEVSTACK_ALLOCATION_START,end=$DEVSTACK_ALLOCATION_END
      PUBLIC_NETWORK_GATEWAY="$DEVSTACK_PRIVATE_GATEWAY"
      PUBLIC_INTERFACE=eth0

      # Disable security groups
      # Q_USE_SECGROUP=False
      # LIBVIRT_FIREWALL_DRIVER=nova.virt.firewall.NoopFirewallDriver

      # Open vSwitch provider networking configuration
      Q_USE_PROVIDERNET_FOR_PUBLIC=True
      OVS_PHYSICAL_BRIDGE=br-ex
      PUBLIC_BRIDGE=br-ex
      OVS_BRIDGE_MAPPINGS=public:br-ex

      USE_PYTHON3=True

      [[post-config|/etc/nova/nova.conf]]

      [libvirt]
      cpu_mode = host-passthrough

      EOF
      ./stack.sh

      source accrc/admin/admin
      openstack project create --domain default --description "New Project" "$OS_PROJECT_NAME"
      openstack user create --domain default --project "$OS_PROJECT_NAME" --password "$OPENSTACK_PASS" "$OPENSTACK_USER"
      openstack role add --project "$OS_PROJECT_NAME" --user "$OPENSTACK_USER" admin

      openstack network set --disable-port-security public
      openstack subnet set --dhcp public-subnet
      openstack subnet set --dns-nameserver 8.8.4.4 public-subnet
      openstack network set --share public
      openstack network set --share private

      for image in `echo "$IMAGE_LIST"`; do
        file_name=\`echo "\$image" | rev | cut -d "/" -f 1 | rev\`
        image_name=\`echo "\$file_name" | rev | cut -d "." -f 2- | rev\`
        wget -O /tmp/"\$file_name" "\$image"
        openstack image create --disk-format qcow2 --public --file /tmp/"\$file_name" --property img_config_drive=mandatory "\$image_name"
      done

runcmd:
  - echo "nameserver 8.8.4.4" >> /etc/resolvconf/resolv.conf.d/head
  - echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/head
  - service resolvconf restart
  - su -l stack ./start.sh
  - iptables -t nat -F POSTROUTING
  - iptables -t nat -A POSTROUTING -o br-ex -j MASQUERADE
  - iptables -t nat -A PREROUTING -d "$DEVSTACK_PUBLIC_IP" -j DNAT --to-destination $DEVSTACK_PRIVATE_IP
EOF

DEVSTACK_IMAGE="UbuntuLTS"
DEVSTACK_SECURITY_GROUP=$DEVSTACK_NAME"-SG"

az network nsg create --resource-group "$DEVSTACK_RG" \
                      --name "$DEVSTACK_SECURITY_GROUP"

$DIR/create_sg_rule.sh "$DEVSTACK_RG" "$DEVSTACK_SECURITY_GROUP" '*' "22" "$USER_PUBLIC_IP_PREFIX" '*' '*' "SSH" "100"
$DIR/create_sg_rule.sh "$DEVSTACK_RG" "$DEVSTACK_SECURITY_GROUP" '*' "80" "$USER_PUBLIC_IP_PREFIX" '*' '*' "HORIZON" "110"

az vm create --name "$DEVSTACK_NAME" \
             --resource-group "$DEVSTACK_RG" \
             --size "$DEVSTACK_VM_SIZE" \
             --admin-username "$ADMIN_USER" \
             --ssh-key-value @"$PUBLIC_KEY" \
             --os-disk-size-gb "$DEVSTACK_DISK_SIZE" \
             --image "$DEVSTACK_IMAGE" \
             --location "$DEVSTACK_LOCATION" \
             --subnet-address-prefix "$SUBNET_CIDR" \
             --subnet "$DEVSTACK_SUBNET_NAME" \
             --vnet-address-prefix "$SUBNET_CIDR" \
             --vnet-name "$DEVSTACK_VNET_NAME" \
             --custom-data "$DATA_FILE" \
             --nsg "$DEVSTACK_SECURITY_GROUP" \
             --private-ip-address "$DEVSTACK_PRIVATE_IP" \
             --public-ip-address "DEVSTACK_PUBLIC_IP"
echo ""

az network vnet subnet update --resource-group="$DEVSTACK_RG" \
                              --name "$DEVSTACK_SUBNET_NAME" \
                              --vnet-name "$DEVSTACK_VNET_NAME" \
                              --network-security-group "$DEVSTACK_SECURITY_GROUP"

DEVSTACK_NIC_ID=`az vm nic list --resource-group ${DEVSTACK_RG} --vm-name ${DEVSTACK_NAME} --query "[0] | id" --output tsv`

### Enabling IP Forwarding on DEVSTACK vnic ###
az network nic update --ids "$DEVSTACK_NIC_ID" --ip-forwarding

