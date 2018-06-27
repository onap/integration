#!/bin/bash -x
#
# Copyright 2018 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <env-name>"
    exit 1
fi
ENV_FILE=$1

SSH_KEY=~/.ssh/onap_key

source $WORKSPACE/test/ete/scripts/install_openstack_cli.sh

SO_ENCRYPTION_KEY=aa3871669d893c7fb8abbcda31b88b4f
export OS_PASSWORD_ENCRYPTED=$(echo -n "$OS_PASSWORD" | openssl aes-128-ecb -e -K "$SO_ENCRYPTION_KEY" -nosalt | xxd -c 256 -p)

for n in $(seq 1 5); do
    $WORKSPACE/test/ete/scripts/teardown-onap.sh

    cd $WORKSPACE/deployment/heat/onap-oom
    envsubst < $ENV_FILE > $ENV_FILE~

    if ! openstack stack create -t ./onap-oom.yaml -e $ENV_FILE~ onap-oom; then
        break
    fi

    while [ "CREATE_IN_PROGRESS" == "$(openstack stack show -c stack_status -f value onap-oom)" ]; do
        sleep 20
    done

    STATUS=$(openstack stack show -c stack_status -f value onap-oom)
    echo $STATUS
    if [ "CREATE_COMPLETE" != "$STATUS" ]; then
        break
    fi

    for i in $(seq 1 30); do
	sleep 30
	RANCHER_IP=$(openstack stack output show onap-oom rancher_vm_ip -c output_value -f value)
        K8S_IP=$(openstack stack output show onap-oom k8s_1_vm_ip -c output_value -f value)
	timeout 1 ping -c 1 "$RANCHER_IP" && break
    done

    timeout 1 ping -c 1 "$RANCHER_IP" && break

    echo Error: OpenStack infrastructure issue: unable to reach rancher "$RANCHER_IP"
    sleep 10
done

if ! timeout 1 ping -c 1 "$RANCHER_IP"; then
    exit 2
fi

ssh-keygen -R $RANCHER_IP

ssh -o StrictHostKeychecking=no -i $SSH_KEY ubuntu@$RANCHER_IP "sed -u '/Cloud-init.*finished/q' <(tail -n+0 -f /var/log/cloud-init-output.log)"

for n in $(seq 1 6); do
    echo "Wait count $n of 6"
    sleep 15m
    timeout 15m ssh -i $SSH_KEY ubuntu@$RANCHER_IP  'sudo su -l root -c "/root/oom/kubernetes/robot/ete-k8s.sh onap health"'
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
  	break
    fi
done
ROBOT_POD=$(ssh -i $SSH_KEY ubuntu@$RANCHER_IP 'sudo su -c "kubectl --namespace onap get pods"' | grep robot | sed 's/ .*//')
if [ "$ROBOT_POD" == "" ]; then
    exit 1
fi

LOG_DIR=$(echo "kubectl exec -n onap $ROBOT_POD -- ls -1t /share/logs | grep health | head -1" | ssh -i $SSH_KEY ubuntu@$RANCHER_IP sudo su)
if [ "$LOG_DIR" == "" ]; then
    exit 1
fi

echo "kubectl cp -n onap $ROBOT_POD:share/logs/$LOG_DIR /tmp/robot/logs/$LOG_DIR" | ssh -i $SSH_KEY ubuntu@$RANCHER_IP sudo su
rsync -e "ssh -i $SSH_KEY" -avtz ubuntu@$RANCHER_IP:/tmp/robot/logs/$LOG_DIR/ $WORKSPACE/archives/

echo "Browse Robot results at http://$K8S_IP:30209/logs/$LOG_DIR/"

exit 0
