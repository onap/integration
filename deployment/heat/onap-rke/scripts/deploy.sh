#!/bin/bash
#
# Copyright 2018 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

stack_name="onap"
portal_hostname="portal.api.simpledemo.onap.org"
full_deletion=false

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

usage() {
    echo "Usage: $0 [ -n <number of VMs {2-15}> ][ -s <stack name> ][ -m <manifest> ][ -d <domain> ][ -r ][ -q ] <env>" 1>&2;

    echo "n:    Set the number of VM's that will be installed. This number must be between 2 and 15" 1>&2;
    echo "s:    Set the name to be used for stack. This name will be used for naming of resources" 1>&2;
    echo "d:    Set the base domain name to be used in portal UI URLs" 1>&2;
    echo "m:    The docker manifest to apply; must be either \"docker-manifest-staging.csv\" or \"docker-manifest.csv\"." 1>&2;
    echo "r:    Delete all resources relating to ONAP within enviroment." 1>&2;
    echo "q:    Quiet Delete of all ONAP resources." 1>&2;

    exit 1;
}


while getopts ":n:s:d:m:rq" o; do
    case "${o}" in
        n)
            if [[ ${OPTARG} =~ ^[0-9]+$ ]];then
                if [ ${OPTARG} -ge 2 -a ${OPTARG} -le 15 ]; then
                    vm_num=${OPTARG}
                else
                    usage
                fi
            else
                usage
            fi
            ;;
        s)
            if [[ ! ${OPTARG} =~ ^[0-9]+$ ]];then
                stack_name=${OPTARG}
            else
                usage
            fi
            ;;
        d)
            if [[ ! ${OPTARG} =~ ^[0-9]+$ ]];then
                portal_hostname=${OPTARG}
            else
                usage
            fi
            ;;
        m)
            if [ -f $WORKSPACE/version-manifest/src/main/resources/${OPTARG} ]; then
                docker_manifest=${OPTARG}
            else
                usage
            fi
            ;;
        r)
            echo "The following command will delete all information relating to onap within your enviroment"
            read -p "Are you certain this is what you want? (type y to confirm):" answer

            if [ $answer = "y" ] || [ $answer = "Y" ] || [ $answer = "yes" ] || [ $answer = "Yes"]; then
                echo "This may delete the work of other colleages within the same enviroment"
                read -p "Are you certain this is what you want? (type y to confirm):" answer2

                if [ $answer2 = "y" ] || [ $answer2 = "Y" ] || [ $answer2 = "yes" ] || [ $answer2 = "Yes"]; then
                    full_deletion=true
                else
                    echo "Ending program"
                    exit 1
                fi
            else
                echo "Ending program"
                exit 1
            fi
            ;;
        q)
            full_deletion=true
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ "$#" -ne 1 ]; then
   usage
fi

ENV_FILE=$1

if [ ! -f $ENV_FILE ];then
    echo ENV file does not exist or was not given
    exit 1
fi

set -x

SSH_KEY=~/.ssh/onap_key

source $WORKSPACE/test/ete/scripts/install_openstack_cli.sh

#Use new encryption method
pushd $WORKSPACE/deployment/heat/onap-rke/scripts
javac Crypto.java
SO_ENCRYPTION_KEY=aa3871669d893c7fb8abbcda31b88b4f
export OS_PASSWORD_ENCRYPTED=$(java Crypto "$OS_PASSWORD" "$SO_ENCRYPTION_KEY")
popd

for n in $(seq 1 5); do
    if [ $full_deletion = true ] ; then
        $WORKSPACE/test/ete/scripts/teardown-onap.sh -n $stack_name -q
    else
        $WORKSPACE/test/ete/scripts/teardown-onap.sh -n $stack_name
    fi

    cd $WORKSPACE/deployment/heat/onap-rke
    envsubst < $ENV_FILE > $ENV_FILE~
    if [ -z "$vm_num" ]; then
        cp onap-oom.yaml onap-oom.yaml~
    else
        ./scripts/gen-onap-oom-yaml.sh $vm_num > onap-oom.yaml~
    fi

    if ! openstack stack create -t ./onap-oom.yaml~ -e $ENV_FILE~ $stack_name --parameter docker_manifest=$docker_manifest --parameter portal_hostname=$portal_hostname; then
        break
    fi

    while [ "CREATE_IN_PROGRESS" == "$(openstack stack show -c stack_status -f value $stack_name)" ]; do
        sleep 20
    done

    STATUS=$(openstack stack show -c stack_status -f value $stack_name)
    echo $STATUS
    if [ "CREATE_COMPLETE" != "$STATUS" ]; then
        break
    fi

    for i in $(seq 1 30); do
	sleep 30
	RANCHER_IP=$(openstack stack output show $stack_name rancher_vm_ip -c output_value -f value)
        K8S_IP=$(openstack stack output show $stack_name k8s_01_vm_ip -c output_value -f value)
	timeout 1 ping -c 1 "$RANCHER_IP" && break
    done

    timeout 1 ping -c 1 "$RANCHER_IP" && break

    echo Error: OpenStack infrastructure issue: unable to reach rancher "$RANCHER_IP"
    sleep 10
done

if ! timeout 1 ping -c 1 "$RANCHER_IP"; then
    exit 2
fi

# wait until all k8s VMs have fully initialized
for VM_NAME in $(grep _vm: ./onap-oom.yaml~ | cut -d: -f1); do
    echo $VM_NAME
    VM_IP=$(openstack stack output show $stack_name ${VM_NAME}_ip -c output_value -f value)
    ssh-keygen -R $VM_IP
    until ssh -o StrictHostKeychecking=no -i $SSH_KEY ubuntu@$VM_IP ls -ad /dockerdata-nfs/.git; do
        sleep 1m
    done
done

cat > ./cluster.yml~ <<EOF
# GENERATED for $stack_name
nodes:
EOF

for VM_NAME in $(grep -E 'k8s_.+_vm:' ./onap-oom.yaml~ | cut -d: -f1); do
    echo $VM_NAME
    VM_IP=$(openstack stack output show $stack_name ${VM_NAME}_ip -c output_value -f value)
    VM_PRIVATE_IP=$(openstack stack output show $stack_name ${VM_NAME}_private_ip -c output_value -f value)
    VM_HOSTNAME=$stack_name-$(echo $VM_NAME | tr '_' '-' | cut -d- -f1,2)
    cat >> ./cluster.yml~ <<EOF
- address: $VM_IP
  port: "22"
  internal_address: $VM_PRIVATE_IP
  role:
  - worker
  hostname_override: "$VM_HOSTNAME"
  user: ubuntu
  ssh_key_path: "$SSH_KEY"
EOF
done

for VM_NAME in $(grep -E 'orch_.+_vm:' ./onap-oom.yaml~ | cut -d: -f1); do
    echo $VM_NAME
    VM_IP=$(openstack stack output show $stack_name ${VM_NAME}_ip -c output_value -f value)
    VM_PRIVATE_IP=$(openstack stack output show $stack_name ${VM_NAME}_private_ip -c output_value -f value)
    VM_HOSTNAME=$stack_name-$(echo $VM_NAME | tr '_' '-' | cut -d- -f1,2)
    cat >> ./cluster.yml~ <<EOF
- address: $VM_IP
  port: "22"
  internal_address: $VM_PRIVATE_IP
  role:
  - controlplane
  - etcd
  hostname_override: "$VM_HOSTNAME"
  user: ubuntu
  ssh_key_path: "$SSH_KEY"
EOF
done

DOCKER_PROXY=$(openstack stack output show $stack_name docker_proxy -c output_value -f value)

cat >> ./cluster.yml~ <<EOF
services:
  kube-api:
    service_cluster_ip_range: 10.43.0.0/16
    pod_security_policy: false
    always_pull_images: false
  kube-controller:
    cluster_cidr: 10.42.0.0/16
    service_cluster_ip_range: 10.43.0.0/16
  kubelet:
    cluster_domain: cluster.local
    cluster_dns_server: 10.43.0.10
    fail_swap_on: false
network:
  plugin: canal
authentication:
  strategy: x509
ssh_key_path: "$SSH_KEY"
ssh_agent_auth: false
authorization:
  mode: rbac
ignore_docker_version: false
kubernetes_version: "v1.13.4-rancher1-2"
private_registries:
- url: $DOCKER_PROXY
  is_default: true
cluster_name: "$stack_name"
restore:
  restore: false
  snapshot_name: ""
EOF

rm -rf ./target
mkdir -p ./target
cp ./cluster.yml~ ./target/cluster.yml
pushd ./target

# spin up k8s with RKE
until rke up; do
    sleep 1m
    rke remove
done

scp ./kube_config_cluster.yml root@$RANCHER_IP:/root/.kube/config
popd


sleep 2m
ssh -o StrictHostKeychecking=no -i $SSH_KEY ubuntu@$RANCHER_IP "sed -u '/Cloud-init.*finished/q' <(tail -n+0 -f /var/log/cloud-init-output.log)"

exit 0
