#!/bin/bash

set -x

DOCKER_VERSION=17.03
RANCHER_VERSION=1.6.18
KUBECTL_VERSION=1.8.10
HELM_VERSION=2.9.1

# setup root access - default login: oom/oom - comment out to restrict access too ssh key only
sed -i 's/PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
service sshd restart
echo -e "oom\noom" | passwd root

apt-get update
curl https://releases.rancher.com/install-docker/$DOCKER_VERSION.sh | sh
mkdir -p /etc/systemd/system/docker.service.d/
cat > /etc/systemd/system/docker.service.d/docker.conf << EOF
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// --insecure-registry=nexus3.onap.org:10001
EOF
systemctl daemon-reload
systemctl restart docker
apt-mark hold docker-ce

#IP_ADDY=`ip address |grep ens|grep inet|awk '{print $2}'| awk -F / '{print $1}'`
#HOSTNAME=`hostname`

#echo "$IP_ADDY $HOSTNAME" >> /etc/hosts

docker login -u docker -p docker nexus3.onap.org:10001

sudo apt-get install make -y

sudo docker run -d --restart=unless-stopped -p 8080:8080 --name rancher_server rancher/server:v$RANCHER_VERSION
sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
sudo mkdir ~/.kube
wget http://storage.googleapis.com/kubernetes-helm/helm-v${HELM_VERSION}-linux-amd64.tar.gz
sudo tar -zxvf helm-v${HELM_VERSION}-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

# nfs server
sudo apt-get install nfs-kernel-server -y

sudo mkdir -p /nfs_share
sudo chown nobody:nogroup /nfs_share/


sudo mkdir -p /dockerdata-nfs
sudo chmod 777 -R /dockerdata-nfs
sudo chown nobody:nogroup /dockerdata-nfs/

NFS_EXP="*(rw,sync,no_root_squash,no_subtree_check) "

echo "/dockerdata-nfs "$NFS_EXP | sudo tee -a /etc/exports

#Restart the NFS service
sudo exportfs -a
sudo systemctl restart nfs-kernel-server

echo "wait before installing rancher server"
sleep 60

# Create ONAP environment on rancher and register the nodes...
SERVER=$1
PRIVATE_IP=$2
NODE_COUNT=$3

echo "SERVER: ${SERVER}"
echo "PRIVATE_IP: ${PRIVATE_IP}"
echo "NODE_COUNT: ${NODE_COUNT}"
#install sshpass to login to the k8s nodes to run rancher agent
sudo apt-get install sshpass

# create kubernetes environment on rancher using cli
RANCHER_CLI_VER=0.6.7
KUBE_ENV_NAME='onap'
wget https://releases.rancher.com/cli/v${RANCHER_CLI_VER}/rancher-linux-amd64-v${RANCHER_CLI_VER}.tar.gz
sudo tar -zxvf rancher-linux-amd64-v${RANCHER_CLI_VER}.tar.gz
sudo cp rancher-v${RANCHER_CLI_VER}/rancher .
sudo chmod +x ./rancher

sudo apt install jq -y
echo "wait for rancher server container to finish - 3 min"
sleep 60
echo "2 more min"
sleep 60
echo "1 min left"
sleep 60
echo "get public and private tokens back to the rancher server so we can register the client later"
API_RESPONSE=`curl -s 'http://$SERVER:8080/v2-beta/apikey' -d '{"type":"apikey","accountId":"1a1","name":"autoinstall","description":"autoinstall","created":null,"kind":null,"removeTime":null,"removed":null,"uuid":null}'`
# Extract and store token
echo "API_RESPONSE: $API_RESPONSE"
KEY_PUBLIC=`echo $API_RESPONSE | jq -r .publicValue`
KEY_SECRET=`echo $API_RESPONSE | jq -r .secretValue`
echo "publicValue: $KEY_PUBLIC secretValue: $KEY_SECRET"

export RANCHER_URL=http://${SERVER}:8080
export RANCHER_ACCESS_KEY=$KEY_PUBLIC
export RANCHER_SECRET_KEY=$KEY_SECRET
./rancher env ls
echo "wait 60 sec for rancher environments can settle before we create the onap kubernetes one"
sleep 60

echo "Creating kubernetes environment named ${KUBE_ENV_NAME}"
./rancher env create -t kubernetes $KUBE_ENV_NAME > kube_env_id.json
PROJECT_ID=$(<kube_env_id.json)
echo "env id: $PROJECT_ID"
export RANCHER_HOST_URL=http://${SERVER}:8080/v1/projects/$PROJECT_ID
echo "you should see an additional kubernetes environment usually with id 1a7"
./rancher env ls
# optionally disable cattle env

# add host registration url
# https://github.com/rancher/rancher/issues/2599
# wait for REGISTERING to ACTIVE
echo "sleep 60 to wait for REG to ACTIVE"
./rancher env ls
sleep 30
echo "check on environments again before registering the URL response"
./rancher env ls
sleep 30
REG_URL_RESPONSE=`curl -X POST -u $KEY_PUBLIC:$KEY_SECRET -H 'Accept: application/json' -H 'ContentType: application/json' -d '{"name":"$SERVER"}' "http://$SERVER:8080/v1/projects/$PROJECT_ID/registrationtokens"`
echo "REG_URL_RESPONSE: $REG_URL_RESPONSE"
echo "wait for server to finish url configuration - 2 min"
sleep 60
echo "60 more sec"
sleep 60

# see registrationUrl in
REGISTRATION_TOKENS=`curl http://$SERVER:8080/v2-beta/registrationtokens`
echo "REGISTRATION_TOKENS: $REGISTRATION_TOKENS"
REGISTRATION_URL=`echo $REGISTRATION_TOKENS | jq -r .data[0].registrationUrl`
REGISTRATION_DOCKER=`echo $REGISTRATION_TOKENS | jq -r .data[0].image`
REGISTRATION_TOKEN=`echo $REGISTRATION_TOKENS | jq -r .data[0].token`
echo "Registering host for image: $REGISTRATION_DOCKER url: $REGISTRATION_URL registrationToken: $REGISTRATION_TOKEN"
HOST_REG_COMMAND=`echo $REGISTRATION_TOKENS | jq -r .data[0].command`

#Loop using the private IP and the no of VMS to SSH into each machine
for i in `seq 1 $((${NODE_COUNT}-1))`;
do
	NODE_IP=${PRIVATE_IP}$i
	sshpass -p "oom" ssh -o StrictHostKeyChecking=no root@${NODE_IP} "hostnamectl set-hostname node$i && docker run --rm --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/racher:/var/lib/rancher $REGISTRATION_DOCKER $RANCHER_URL/v1/scripts/$REGISTRATION_TOKEN"
done

echo "waiting 10 min for host registration to finish"
sleep 540
echo "1 more min"
sleep 60
#read -p "wait for host registration to complete before generating the client token....."

# base64 encode the kubectl token from the auth pair
# generate this after the host is registered
KUBECTL_TOKEN=$(echo -n 'Basic '$(echo -n "$RANCHER_ACCESS_KEY:$RANCHER_SECRET_KEY" | base64 -w 0) | base64 -w 0)
echo "KUBECTL_TOKEN base64 encoded: ${KUBECTL_TOKEN}"
# add kubectl config - NOTE: the following spacing has to be "exact" or kubectl will not connect - with a localhost:8080 error
cat > ~/.kube/config <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    api-version: v1
    insecure-skip-tls-verify: true
    server: "https://$SERVER:8080/r/projects/$PROJECT_ID/kubernetes:6443"
  name: "${ENVIRON}"
contexts:
- context:
    cluster: "${ENVIRON}"
    user: "${ENVIRON}"
  name: "${ENVIRON}"
current-context: "${ENVIRON}"
users:
- name: "${ENVIRON}"
  user:
    token: "$KUBECTL_TOKEN"

EOF

echo "run the following if you installed a higher kubectl version than the server"
echo "helm init --upgrade"
echo "Verify all pods up on the kubernetes system - will return localhost:8080 until a host is added"
echo "kubectl get pods --all-namespaces"
kubectl get pods --all-namespaces


exit 0
