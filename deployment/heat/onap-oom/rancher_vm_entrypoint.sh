#!/bin/bash -x
printenv

mkdir -p /opt/config
echo "__rancher_ip_addr__" > /opt/config/rancher_ip_addr.txt
echo "__k8s_vm_ips__" > /opt/config/k8s_vm_ips.txt
echo "__oam_network_id__" > /opt/config/oam_network_id.txt
echo "__oam_subnet_id__" > /opt/config/oam_subnet_id.txt

cat <<EOF > /opt/config/integration-override.yaml
__integration_override_yaml__
EOF
sed -i 's/\_\_oam_network_id__/__oam_network_id__/g' /opt/config/integration-override.yaml
sed -i 's/\_\_oam_subnet_id__/__oam_subnet_id__/g' /opt/config/integration-override.yaml
cp /opt/config/integration-override.yaml /root

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
apt-get -y install linux-image-extra-$(uname -r) jq make nfs-kernel-server


# version control the persistence volume to see what's happening
mkdir -p /dockerdata-nfs/
chmod 777 /dockerdata-nfs/
chown nobody:nogroup /dockerdata-nfs/
cd /dockerdata-nfs/
git init
git config user.email "root@onap"
git config user.name "root"
git add -A
git commit -m "initial commit"

# export NFS mount
NFS_EXP=""
for K8S_VM_IP in $(tr -d ',[]' < /opt/config/k8s_vm_ips.txt); do
    NFS_EXP+="$K8S_VM_IP(rw,sync,no_root_squash,no_subtree_check) "
done
echo "/dockerdata-nfs $NFS_EXP" | tee /etc/exports


exportfs -a
systemctl restart nfs-kernel-server

cd ~

# install docker 17.03
curl -s https://releases.rancher.com/install-docker/17.03.sh | sh
usermod -aG docker ubuntu

docker run --restart unless-stopped -d -p 8080:8080  -e CATTLE_BOOTSTRAP_REQUIRED_IMAGE=__docker_proxy__/rancher/agent:v1.2.9 __docker_proxy__/rancher/server:v1.6.14

# install kubernetes 1.8.6
curl -s -LO https://storage.googleapis.com/kubernetes-release/release/v1.8.10/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
mkdir ~/.kube

# install helm
wget -q http://storage.googleapis.com/kubernetes-helm/helm-v2.8.2-linux-amd64.tar.gz
tar -zxvf helm-v2.8.2-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

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


curl -u "${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY}" -X PUT -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"id":"registry.default","type":"activeSetting","baseType":"setting","name":"registry.default","activeValue":"__docker_proxy__","inDb":true,"source":"Database","value":"__docker_proxy__"}'  http://$RANCHER_IP:8080/v2-beta/settings/registry.default

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


curl -s -u $RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"name":"docker-proxy", "serverAddress":"__docker_proxy__"}' $RANCHER_URL/registries > registry.json
RID=$(jq -r '.id' registry.json)


curl -u "${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY}" -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"publicValue":"docker", "registryId":"'$RID'", "secretValue":"docker", "type":"registryCredential"}' "http://$RANCHER_IP:8080/v2-beta/projects/$PID/registrycredential"



TID=$(curl -s -X POST -H "Accept: application/json" -H "Content-Type: application/json" http://$RANCHER_IP:8080/v1/projects/$PID/registrationTokens | jq -r '.id')
touch token.json
while [ $(jq -r .command token.json | wc -c) -lt 10 ]; do
    sleep 5
    curl -s -X GET -H "Accept: application/json" http://$RANCHER_IP:8080/v1/projects/$PID/registrationToken/$TID > token.json
done
jq -r .command token.json > rancher_agent_cmd.sh
chmod +x rancher_agent_cmd.sh
cp rancher_agent_cmd.sh /dockerdata-nfs
cd /dockerdata-nfs
git add -A
git commit -a -m "Add rancher agent command file"
cd ~


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
cd oom
git log -1

# Run ONAP:
cd ~/oom/kubernetes/
helm init --client-only
helm init --upgrade
helm serve &
sleep 3
helm repo add local http://127.0.0.1:8879
helm repo list
make all
helm search -l | grep local
helm install local/onap -n dev --namespace onap -f ~/integration-override.yaml


# Check ONAP status:
sleep 3
kubectl get pods --all-namespaces
