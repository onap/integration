#!/bin/bash -x

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <env-name>"
    exit 1
fi
ENV_FILE=$1

source $WORKSPACE/test/ete/scripts/install_openstack_cli.sh

SO_ENCRYPTION_KEY=aa3871669d893c7fb8abbcda31b88b4f
export OS_PASSWORD_ENCRYPTED=$(echo -n "$OS_PASSWORD" | openssl aes-128-ecb -e -K "$SO_ENCRYPTION_KEY" -nosalt | xxd -c 256 -p)

for n in $(seq 1 5); do
    $WORKSPACE/test/ete/scripts/teardown-onap.sh

    cd $WORKSPACE/deployment/heat/onap-oom
    envsubst < $ENV_FILE > $ENV_FILE~
    openstack stack create -t ./onap-oom.yaml -e $ENV_FILE~ onap-oom

    for i in $(seq 1 30); do
	sleep 30
	RANCHER_IP=$(openstack stack output show onap-oom rancher_vm_ip -c output_value -f value)
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
for n in $(seq 1 10); do
    timeout 15m ssh -o StrictHostKeychecking=no -i ~/.ssh/onap_key ubuntu@$RANCHER_IP  'sudo su -l root -c "/root/oom/kubernetes/robot/ete-k8s.sh onap health"'
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
  	break
    fi
    sleep 15m
done
ROBOT_POD=$(ssh -o StrictHostKeychecking=no -i ~/.ssh/onap_key ubuntu@$RANCHER_IP 'sudo su -c "kubectl --namespace onap get pods"' | grep robot | sed 's/ .*//')
LOG_DIR=$(ssh -o StrictHostKeychecking=no -i ~/.ssh/onap_key ubuntu@$RANCHER_IP "sudo su -c \"kubectl exec $ROBOT_POD --namespace onap -- ls -1t /share/logs | head -1\"")

K8S_IP=$(openstack stack output show onap-oom k8s_1_vm_ip -c output_value -f value)
wget --user=robot --password=robot -r -np -nH --cut-dirs=2 -R "index.html*" -P $WORKSPACE/archives/ http://$K8S_IP:30209/logs/$LOG_DIR/
exit 0
