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
wget -q http://storage.googleapis.com/kubernetes-helm/helm-v2.7.2-linux-amd64.tar.gz
tar -zxvf helm-v2.7.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

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

# wait for kubernetes to initialze
sleep 100
until [ $(kubectl get pods --namespace kube-system | tail -n +2 | grep -c Running) -ge 6 ]; do
    sleep 10
done


# Install using OOM
export HOME=/root

# Clone OOM:
cd ~
git clone -b master http://gerrit.onap.org/r/oom
git log -1

# Update values.yaml to point to docker-proxy instead of nexus3:
cd ~/oom/kubernetes
#perl -p -i -e 's/nexus3.onap.org:10001/__docker_proxy__/g' `find ./ -name values.yaml`
sed -i 's/nexus3.onap.org:10001/__docker_proxy__/g' onap/values.yaml
sed -i 's/#repository:/repository:/g' onap/values.yaml
sed -i 's/#repositorySecret:/repositorySecret:/g' onap/values.yaml
git diff


# version control the persistence volume to see what's happening
mkdir -p /dockerdata-nfs/
cd /dockerdata-nfs/
git init
git config user.email "root@k8s"
git config user.name "root"
git add -A
git commit -m "initial commit"

# Run ONAP:
cd ~/oom/kubernetes/
# verify version
helm version
helm init --client-only
helm init --upgrade
helm serve &
sleep 3
helm repo add local http://127.0.0.1:8879
helm repo list
make all
helm search -l | grep local
helm install local/onap -n dev --namespace onap

# Check ONAP status:
sleep 3
kubectl get pods --all-namespaces
