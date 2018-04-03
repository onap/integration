#!/bin/bash -x
printenv

mkdir -p /opt/config
echo "__rancher_ip_addr__" > /opt/config/rancher_ip_addr.txt
echo `hostname -I` `hostname` >> /etc/hosts
mkdir -p /etc/docker
if [ ! -z "__docker_proxy__" ]; then
    cat > /etc/docker/daemon.json <<EOF
{
  "insecure-registries" : ["__docker_proxy__"]
}
EOF
fi
if [ ! -z "__apt_proxy__" ]; then
    cat > /etc/apt/apt.conf.d/30proxy<<EOF
Acquire::http { Proxy "http://__apt_proxy__"; };
Acquire::https::Proxy "DIRECT";
EOF
fi
apt-get -y update
apt-get -y install linux-image-extra-$(uname -r) jq make

cd ~

# install docker 17.03
curl -s https://releases.rancher.com/install-docker/17.03.sh | sh
usermod -aG docker ubuntu

# install kubernetes 1.8.6
curl -s -LO https://storage.googleapis.com/kubernetes-release/release/v1.8.6/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
mkdir ~/.kube

# install helm
wget -q http://storage.googleapis.com/kubernetes-helm/helm-v2.6.1-linux-amd64.tar.gz
tar -zxvf helm-v2.6.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
# verify version
helm version
# Rancher 1.6.14 installs 2.6.1 - if you upgrade to 2.8.0 - you will need to upgrade helm on the server to the version to level of client
helm init --upgrade

# Fix virtual memory allocation for onap-log:elasticsearch:
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -p

# install rancher agent
echo export RANCHER_IP=__rancher_ip_addr__ > api-keys-rc
source api-keys-rc

sleep 50
until curl -s -o projects.json -H "Accept: application/json" http://$RANCHER_IP:8080/v2-beta/projects; do
    sleep 10
done
OLD_PID=$(jq -r '.data[0].id' projects.json)

curl -s -H "Accept: application/json" -H "Content-Type: application/json" -d '{"accountId":"1a1"}' http://$RANCHER_IP:8080/v2-beta/apikeys > apikeys.json
echo export RANCHER_ACCESS_KEY=`jq -r '.publicValue' apikeys.json` >> api-keys-rc
echo export RANCHER_SECRET_KEY=`jq -r '.secretValue' apikeys.json` >> api-keys-rc
source api-keys-rc

curl -s -u "${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY}" -X DELETE -H 'Content-Type: application/json' "http://$RANCHER_IP:8080/v2-beta/projects/$OLD_PID"

until [ ! -z "$TEMPLATE_ID" ] && [ "$TEMPLATE_ID" != "null" ]; do
    sleep 5
    curl -s -H "Accept: application/json" http://$RANCHER_IP:8080/v2-beta/projectTemplates?name=Kubernetes > projectTemplatesKubernetes.json
    TEMPLATE_ID=$(jq -r '.data[0].id' projectTemplatesKubernetes.json)
done

curl -s -u "${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY}" -X POST -H 'Content-Type: application/json' -d '{ "name":"oom", "projectTemplateId":"'$TEMPLATE_ID'" }' "http://$RANCHER_IP:8080/v2-beta/projects" > project.json
PID=`jq -r '.id' project.json`
echo export RANCHER_URL=http://$RANCHER_IP:8080/v1/projects/$PID >> api-keys-rc
source api-keys-rc

until [ $(jq -r '.state' project.json) == "active" ]; do
    sleep 5
    curl -s -H "Accept: application/json" http://$RANCHER_IP:8080/v1/projects/$PID > project.json
done

TID=$(curl -s -X POST -H "Accept: application/json" -H "Content-Type: application/json" http://$RANCHER_IP:8080/v1/projects/$PID/registrationTokens | jq -r '.id')
touch token.json
while [ $(jq -r .command token.json | wc -c) -lt 10 ]; do
    sleep 5
    curl -s -X GET -H "Accept: application/json" http://$RANCHER_IP:8080/v1/projects/$PID/registrationToken/$TID > token.json
done
RANCHER_AGENT_CMD=$(jq -r .command token.json)
eval $RANCHER_AGENT_CMD

# download rancher CLI
wget -q https://github.com/rancher/cli/releases/download/v0.6.7/rancher-linux-amd64-v0.6.7.tar.xz
unxz rancher-linux-amd64-v0.6.7.tar.xz
tar xvf rancher-linux-amd64-v0.6.7.tar

# Clone OOM:
cd ~
git clone -b master http://gerrit.onap.org/r/oom

# Update values.yaml to point to docker-proxy instead of nexus3:
cd ~/oom/kubernetes
perl -p -i -e 's/nexus3.onap.org:10001/__docker_proxy__/g' `find ./ -name values.yaml`

KUBETOKEN=$(echo -n 'Basic '$(echo -n "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" | base64 -w 0) | base64 -w 0)

# create .kube/config
cat > ~/.kube/config <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    api-version: v1
    insecure-skip-tls-verify: true
    server: "https://$RANCHER_IP:8080/r/projects/$PID/kubernetes:6443"
  name: "oom"
contexts:
- context:
    cluster: "oom"
    user: "oom"
  name: "oom"
current-context: "oom"
users:
- name: "oom"
  user:
    token: "$KUBETOKEN"
EOF

export KUBECONFIG=/root/.kube/config
kubectl config view

# Update ~/oom/kubernetes/kube2msb/values.yaml kubeMasterAuthToken to use the token from ~/.kube/config
sed -i "s/kubeMasterAuthToken:.*/kubeMasterAuthToken: $KUBETOKEN/" ~/oom/kubernetes/kube2msb/values.yaml

# Put your onap_key ssh private key in ~/.ssh/onap_key

# Create or edit ~/oom/kubernetes/config/onap-parameters.yaml
cat > ~/oom/kubernetes/config/onap-parameters.yaml <<EOF
OPENSTACK_UBUNTU_14_IMAGE: "__ubuntu_1404_image__"
OPENSTACK_PUBLIC_NET_ID: "__public_net_id__"
OPENSTACK_OAM_NETWORK_ID: "__oam_network_id__"
OPENSTACK_OAM_SUBNET_ID: "__oam_subnet_id__"
OPENSTACK_OAM_NETWORK_CIDR: "__oam_network_cidr__"
OPENSTACK_USERNAME: "__openstack_username__"
OPENSTACK_API_KEY: "__openstack_api_key__"
OPENSTACK_TENANT_NAME: "__openstack_tenant_name__"
OPENSTACK_TENANT_ID: "__openstack_tenant_id__"
OPENSTACK_REGION: "RegionOne"
OPENSTACK_KEYSTONE_URL: "__keystone_url__"
OPENSTACK_FLAVOUR_MEDIUM: "m1.medium"
OPENSTACK_SERVICE_TENANT_NAME: "service"
DMAAP_TOPIC: "AUTO"
DEMO_ARTIFACTS_VERSION: "1.1.1"
EOF
cat ~/oom/kubernetes/config/onap-parameters.yaml


# wait for kubernetes to initialze
sleep 100
until [ $(kubectl get pods --namespace kube-system | tail -n +2 | grep -c Running) -ge 6 ]; do
    sleep 10
done

# run the config pod creation
cd ~/oom/kubernetes/config
./createConfig.sh -n onap

# Wait until the config container completes.
sleep 20
until [ $(kubectl get pods --namespace onap -a | tail -n +2 | grep -c Completed) -eq 1 ]; do
    sleep 10
done

# version control the config to see what's happening
cd /dockerdata-nfs/
git init
git config user.email "root@k8s"
git config user.name "root"
git add -A
git commit -m "initial commit"

# Run ONAP:
cd ~/oom/kubernetes/
helm init --client-only
helm serve &
sleep 3
helm repo add local http://127.0.0.1:8879
make all
helm install local/onap --name dev --namespace onap

# Check ONAP status:
sleep 3
kubectl get pods --all-namespaces
