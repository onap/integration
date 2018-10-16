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
full_deletion=false

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

usage() {
    echo "Usage: $0 [ -n <number of VMs {2-15}> ][ -s <stack name> ][ -m <manifest> ][ -r ][ -q ] <env>" 1>&2;

    echo "n:    Set the number of VM's that will be installed. This number must be between 2 and 15" 1>&2;
    echo "s:    Set the name to be used for stack. This name will be used for naming of resources" 1>&2;
    echo "m:    The docker manifest to apply; must be either \"docker-manifest-staging.csv\" or \"docker-manifest.csv\"." 1>&2;
    echo "r:    Delete all resources relating to ONAP within enviroment." 1>&2;
    echo "q:    Quiet Delete of all ONAP resources." 1>&2;

    exit 1;
}


while getopts ":n:s:m:rq" o; do
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

SO_ENCRYPTION_KEY=aa3871669d893c7fb8abbcda31b88b4f
export OS_PASSWORD_ENCRYPTED=$(echo -n "$OS_PASSWORD" | openssl aes-128-ecb -e -K "$SO_ENCRYPTION_KEY" -nosalt | xxd -c 256 -p)

for n in $(seq 1 5); do
    if [ $full_deletion = true ] ; then
        $WORKSPACE/test/ete/scripts/teardown-onap.sh -n $stack_name -q
    else
        $WORKSPACE/test/ete/scripts/teardown-onap.sh -n $stack_name
    fi

    cd $WORKSPACE/deployment/heat/onap-oom
    envsubst < $ENV_FILE > $ENV_FILE~
    if [ -z "$vm_num" ]; then
        cp onap-oom.yaml onap-oom.yaml~
    else
        ./scripts/gen-onap-oom-yaml.sh $vm_num > onap-oom.yaml~
    fi

    if ! openstack stack create -t ./onap-oom.yaml~ -e $ENV_FILE~ $stack_name --parameter docker_manifest=$docker_manifest; then
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
        K8S_IP=$(openstack stack output show $stack_name k8s_1_vm_ip -c output_value -f value)
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

sleep 2m
ssh -o StrictHostKeychecking=no -i $SSH_KEY ubuntu@$RANCHER_IP "sed -u '/Cloud-init.*finished/q' <(tail -n+0 -f /var/log/cloud-init-output.log)"

for n in $(seq 1 8); do
    echo "Wait count $n of 8"
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
