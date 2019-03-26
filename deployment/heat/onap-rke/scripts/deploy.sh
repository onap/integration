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

stack_name="oom"
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

#SO_ENCRYPTION_KEY=aa3871669d893c7fb8abbcda31b88b4f
#export OS_PASSWORD_ENCRYPTED=$(echo -n "$OS_PASSWORD" | openssl aes-128-ecb -e -K "$SO_ENCRYPTION_KEY" -nosalt | xxd -c 256 -p)

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
# If you intened to deploy Kubernetes in an air-gapped environment,
# please consult the documentation on how to configure custom RKE images.
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
  docker_socket: /var/run/docker.sock
  ssh_key: ""
  ssh_key_path: ~/.ssh/onap_key
  ssh_cert: ""
  ssh_cert_path: ""
  labels: {}
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
  docker_socket: /var/run/docker.sock
  ssh_key: ""
  ssh_key_path: ~/.ssh/onap_key
  ssh_cert: ""
  ssh_cert_path: ""
  labels: {}
EOF
done

cat >> ./cluster.yml~ <<EOF
services:
  etcd:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
    external_urls: []
    ca_cert: ""
    cert: ""
    key: ""
    path: ""
    snapshot: null
    retention: ""
    creation: ""
    backup_config: null
  kube-api:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
    service_cluster_ip_range: 10.43.0.0/16
    service_node_port_range: ""
    pod_security_policy: false
    always_pull_images: false
  kube-controller:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
    cluster_cidr: 10.42.0.0/16
    service_cluster_ip_range: 10.43.0.0/16
  scheduler:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
  kubelet:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
    cluster_domain: cluster.local
    infra_container_image: ""
    cluster_dns_server: 10.43.0.10
    fail_swap_on: false
  kubeproxy:
    image: ""
    extra_args: {}
    extra_binds: []
    extra_env: []
network:
  plugin: canal
  options: {}
authentication:
  strategy: x509
  sans: []
  webhook: null
addons: ""
addons_include: []
system_images:
  etcd: rancher/coreos-etcd:v3.2.24-rancher1
  alpine: rancher/rke-tools:v0.1.27
  nginx_proxy: rancher/rke-tools:v0.1.27
  cert_downloader: rancher/rke-tools:v0.1.27
  kubernetes_services_sidecar: rancher/rke-tools:v0.1.27
  kubedns: rancher/k8s-dns-kube-dns:1.15.0
  dnsmasq: rancher/k8s-dns-dnsmasq-nanny:1.15.0
  kubedns_sidecar: rancher/k8s-dns-sidecar:1.15.0
  kubedns_autoscaler: rancher/cluster-proportional-autoscaler:1.0.0
  coredns: coredns/coredns:1.2.6
  coredns_autoscaler: rancher/cluster-proportional-autoscaler:1.0.0
  kubernetes: rancher/hyperkube:v1.13.4-rancher1
  flannel: rancher/coreos-flannel:v0.10.0-rancher1
  flannel_cni: rancher/flannel-cni:v0.3.0-rancher1
  calico_node: rancher/calico-node:v3.4.0
  calico_cni: rancher/calico-cni:v3.4.0
  calico_controllers: ""
  calico_ctl: rancher/calico-ctl:v2.0.0
  canal_node: rancher/calico-node:v3.4.0
  canal_cni: rancher/calico-cni:v3.4.0
  canal_flannel: rancher/coreos-flannel:v0.10.0
  weave_node: weaveworks/weave-kube:2.5.0
  weave_cni: weaveworks/weave-npc:2.5.0
  pod_infra_container: rancher/pause:3.1
  ingress: rancher/nginx-ingress-controller:0.21.0-rancher3
  ingress_backend: rancher/nginx-ingress-controller-defaultbackend:1.4-rancher1
  metrics_server: rancher/metrics-server:v0.3.1
ssh_key_path: ~/.ssh/onap_key
ssh_cert_path: ""
ssh_agent_auth: false
authorization:
  mode: rbac
  options: {}
ignore_docker_version: false
kubernetes_version: ""
private_registries: []
ingress:
  provider: ""
  options: {}
  node_selector: {}
  extra_args: {}
cluster_name: "$stack_name"
cloud_provider:
  name: ""
prefix_path: ""
addon_job_timeout: 0
bastion_host:
  address: ""
  port: ""
  user: ""
  ssh_key: ""
  ssh_key_path: ""
  ssh_cert: ""
  ssh_cert_path: ""
monitoring:
  provider: ""
  options: {}
restore:
  restore: false
  snapshot_name: ""
dns: null
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

PREV_RESULT=0
for n in $(seq 1 20); do
  RESULT=$(ssh -i $SSH_KEY ubuntu@$RANCHER_IP 'sudo su -c "kubectl -n onap get pods"' | grep -vE 'Running|Complete|NAME' | wc -l)
  if [[ $? -eq 0 && ( $RESULT -eq 0 || $RESULT -eq $PREV_RESULT ) ]]; then
    break
  fi
  sleep 15m
  PREV_RESULT=$RESULT
done

PREV_RESULT=0
for n in $(seq 1 20); do
  echo "Wait for HEALTHCHECK count $n of 10"
  ROBOT_POD=$(ssh -i $SSH_KEY ubuntu@$RANCHER_IP 'sudo su -c "kubectl --namespace onap get pods"' | grep robot | sed 's/ .*//')
  ssh -i $SSH_KEY ubuntu@$RANCHER_IP  'sudo su -l root -c "/root/oom/kubernetes/robot/ete-k8s.sh onap health"'
  RESULT=$?
  if [[ $RESULT -lt 10 && ( $RESULT -eq 0 || $RESULT -eq $PREV_RESULT ) ]]; then
    break
  fi
  sleep 15m
  PREV_RESULT=$RESULT
done
if [ "$ROBOT_POD" == "" ]; then
  exit 1
fi

LOG_DIR=$(echo "kubectl exec -n onap $ROBOT_POD -- ls -1t /share/logs | grep health | head -1" | ssh -i $SSH_KEY ubuntu@$RANCHER_IP sudo su)
echo "kubectl cp -n onap $ROBOT_POD:share/logs/$LOG_DIR /tmp/robot/logs/$LOG_DIR" | ssh -i $SSH_KEY ubuntu@$RANCHER_IP sudo su
echo "Browse Robot results at http://$K8S_IP:30209/logs/$LOG_DIR/"
mkdir -p $WORKSPACE/archives/healthcheck
rsync -e "ssh -i $SSH_KEY" -avtz ubuntu@$RANCHER_IP:/tmp/robot/logs/$LOG_DIR/ $WORKSPACE/archives/healthcheck

exit 0
