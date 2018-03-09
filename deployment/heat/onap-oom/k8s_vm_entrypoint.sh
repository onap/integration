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
apt-get -y install linux-image-extra-$(uname -r) jq

cd ~

# install docker 1.12
curl -s https://releases.rancher.com/install-docker/1.12.sh | sh
usermod -aG docker ubuntu

# install kubernetes 1.8.6
curl -s -LO https://storage.googleapis.com/kubernetes-release/release/v1.8.6/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
mkdir ~/.kube

# install helm 2.3
wget -q http://storage.googleapis.com/kubernetes-helm/helm-v2.3.0-linux-amd64.tar.gz
tar -zxvf helm-v2.3.0-linux-amd64.tar.gz
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

# download rancher CLI
wget -q https://github.com/rancher/cli/releases/download/v0.6.7/rancher-linux-amd64-v0.6.7.tar.xz
unxz rancher-linux-amd64-v0.6.7.tar.xz
tar xvf rancher-linux-amd64-v0.6.7.tar

# Clone OOM:
cd ~
git clone -b master http://gerrit.onap.org/r/oom

# Update values.yaml to point to docker-proxy instead of nexus3:
cd ~/oom/kubernetes
perl -p -i -e 's/nexus3.onap.org:10001/__docker_proxy__/g' `find ./ -name values.yaml` oneclick/setenv.bash

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
# For information regarding those parameters, please visit http://onap.readthedocs.io/en/latest/submodules/dcaegen2.git/docs/sections/installation_heat.html

#################
# COMMON CONFIG #
#################

# NEXUS
NEXUS_HTTP_REPO: https://nexus.onap.org/content/sites/raw
NEXUS_DOCKER_REPO: nexus3.onap.org:10001
NEXUS_USERNAME: docker
NEXUS_PASSWORD: docker

# ONAP config
# Do not change unless you know what you're doing
DMAAP_TOPIC: "AUTO"
DEMO_ARTIFACTS_VERSION: "1.1.1"

# ------------------------------------------------#
# OpenStack Config on which VNFs will be deployed #
# ------------------------------------------------#

# The four below parameters are only used by Robot.
# As Robot is able to perform some automated actions,
# e.g. onboard/distribute/instantiate, it has to be
# configured with four below parameters (in addition
# to the OPENSTACK ones).
# If you don't intend to use Robot for those actions,
# you can put dummy values, but you will have to provide
# those values when deploying VNF anyway.
# --------------------------------------------------
# This is the OAM Network ID used for internal network by VNFs.
# You could create 10.10.10.0/24 (256 IPs should be enough) in your cloud instance.
OPENSTACK_OAM_NETWORK_ID: "__oam_network_id__"
# This is the public Network ID. Public = external network in OpenStack.
# Floating IPs will be created and assigned to VNFs from this network,
# to provide external reachability.
OPENSTACK_PUBLIC_NETWORK_ID: "__public_net_id__"
# VM Flavor to be used by VNF.
OPENSTACK_FLAVOR: "m1.medium"
# VM image to be used by VNF. Here ubuntu 14.04 is provided.
OPENSTACK_IMAGE: "__ubuntu_1604_image__"

OPENSTACK_USERNAME: "__openstack_username__"
OPENSTACK_PASSWORD: "__openstack_api_key__"
OPENSTACK_TENANT_NAME: "__openstack_tenant_name__"
OPENSTACK_TENANT_ID: "__openstack_tenant_id__"
OPENSTACK_REGION: "RegionOne"
# Either v2.0 or v3
OPENSTACK_API_VERSION: "v2.0"
OPENSTACK_KEYSTONE_URL: "__keystone_url__"
# Don't change this if you don't know what it is
OPENSTACK_SERVICE_TENANT_NAME: "service"

########
# DCAE #
########

# Whether or not to deploy DCAE
# If set to false, all the parameters below can be left empty or removed
# If set to false, update ../dcaegen2/values.yaml disableDcae value to true,
# this is to avoid deploying the DCAE deployments and services.
DEPLOY_DCAE: "true"

# DCAE Config
DCAE_DOCKER_VERSION: v1.1.1
DCAE_VM_BASE_NAME: "dcae"

# ------------------------------------------------#
# OpenStack Config on which DCAE will be deployed #
# ------------------------------------------------#

# Whether to have DCAE deployed on the same OpenStack instance on which VNF will be deployed.
# (e.g. re-use the same config as defined above)
# If set to true, discard the next config block, else provide the values.
IS_SAME_OPENSTACK_AS_VNF: "true"

# Fill in the values in below block only if IS_SAME_OPENSTACK_AS_VNF set to "false"
# ---
# Either v2.0 or v3
DCAE_OS_API_VERSION: "v2.0"
DCAE_OS_KEYSTONE_URL: "__keystone_url__"
DCAE_OS_USERNAME: ""
DCAE_OS_PASSWORD: ""
DCAE_OS_TENANT_NAME: ""
DCAE_OS_TENANT_ID: ""
DCAE_OS_REGION: ""
# ---

# We need to provide the config of the public network here, because the DCAE VMs will be
# assigned a floating IP on this network so one can access them, to debug for instance.
# The ID of the public network.
DCAE_OS_PUBLIC_NET_ID: "__public_net_id__"
# The name of the public network.
DCAE_OS_PUBLIC_NET_NAME: "__public_net_name__"
# This is the private network that will be used by DCAE VMs. The network will be created during the DCAE boostrap process,
# and will the subnet created will use this CIDR. (/28 provides 16 IPs, DCAE requires 15.)
DCAE_OS_OAM_NETWORK_CIDR: "10.99.0.0/16"
# This will be the private ip of the DCAE boostrap VM. This VM is responsible for spinning up the whole DCAE stack (14 VMs total)
DCAE_IP_ADDR: "10.99.4.1"

# The flavors' name to be used by DCAE VMs
DCAE_OS_FLAVOR_SMALL: "m1.small"
DCAE_OS_FLAVOR_MEDIUM: "m1.medium"
DCAE_OS_FLAVOR_LARGE: "m1.large"
# The images' name to be used by DCAE VMs
DCAE_OS_UBUNTU_14_IMAGE: "__ubuntu_1404_image__"
DCAE_OS_UBUNTU_16_IMAGE: "__ubuntu_1604_image__"
DCAE_OS_CENTOS_7_IMAGE: "__centos_7_image__"

# This is the keypair that will be created in OpenStack, and that one can use to access DCAE VMs using ssh.
# The private key needs to be in a specific format so at the end of the process, it's formatted properly
# when ending up in the DCAE HEAT stack. The best way is to do the following:
# - copy paste your key
# - surround it with quote
# - add \n at the end of each line
# - escape the result using https://www.freeformatter.com/java-dotnet-escape.html#ad-output
DCAE_OS_KEY_NAME: "onap_key"
DCAE_OS_PUB_KEY: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKXDgoo3+WOqcUG8/5uUbk81+yczgwC4Y8ywTmuQqbNxlY1oQ0YxdMUqUnhitSXs5S/yRuAVOYHwGg2mCs20oAINrP+mxBI544AMIb9itPjCtgqtE2EWo6MmnFGbHB4Sx3XioE7F4VPsh7japsIwzOjbrQe+Mua1TGQ5d4nfEOQaaglXLLPFfuc7WbhbJbK6Q7rHqZfRcOwAMXgDoBqlyqKeiKwnumddo2RyNT8ljYmvB6buz7KnMinzo7qB0uktVT05FH9Rg0CTWH5norlG5qXgP2aukL0gk1ph8iAt7uYLf1ktp+LJI2gaF6L0/qli9EmVCSLr1uJ38Q8CBflhkh"
DCAE_OS_PRIVATE_KEY: \"-----BEGIN RSA PRIVATE KEY-----\\n\r\nMIIEpQIBAAKCAQEAylw4KKN/ljqnFBvP+blG5PNfsnM4MAuGPMsE5rkKmzcZWNaE\\n\r\nNGMXTFKlJ4YrUl7OUv8kbgFTmB8BoNpgrNtKACDaz/psQSOeOADCG/YrT4wrYKrR\\n\r\nNhFqOjJpxRmxweEsd14qBOxeFT7Ie42qbCMMzo260HvjLmtUxkOXeJ3xDkGmoJVy\\n\r\nyzxX7nO1m4WyWyukO6x6mX0XDsADF4A6AapcqinoisJ7pnXaNkcjU/JY2Jrwem7s\\n\r\n+ypzIp86O6gdLpLVU9ORR/UYNAk1h+Z6K5Rual4D9mrpC9IJNaYfIgLe7mC39ZLa\\n\r\nfiySNoGhei9P6pYvRJlQki69bid/EPAgX5YZIQIDAQABAoIBAQClDekkhI9ZqseC\\n\r\nqFjPuKaxsizZMg+faJb6WSHLSxzyk1OSWY6F6FklgLeC8HW/fuLNYZyGOYDEsG20\\n\r\nlMqL02Wdiy7OutS3oOS5iyzIf9a90HfFJi706el6RIpvINETcaXCS0T8tQrcS1Rd\\n\r\nKqTaBRC6HXJGAPbBcvw3pwQSdskatU6a/Kt2a3x6DsqqinQcgEB/SbrDaJCUX9sb\\n\r\nF2HVUwdq7aZK1Lk0ozr1FID9mrhjwWuQ6XC+vjG0FqtyXeMpR5iaQ73hex3FXQ8z\\n\r\nOjkFbMwuHWSh1DSx70r5yFrrBqwQKnMsBqx4QDRf3fIENUnWviaL+n+gwcXA07af\\n\r\n4kaNUFUtAoGBAPuNNRAGhZnyZ9zguns9PM56nmeMUikV5dPN2DTbQb79cpfV+7pC\\n\r\n6PeSH/dTKFLz62d6qAM2EsNXQvewf8fipBVBRPsRqKOv+uepd01dHNy62I5B+zRm\\n\r\nbe9Kbe+EN60qdzvyPM+2hV6CnvGv1dirimS9pu6RrxD2Rmz1ectnJE+rAoGBAM3w\\n\r\nUbSEemyZ6EKjck2RfdipzY0MNBnIZ2cUqHh8mmPXjdTLzpXb9vmPbHb01Qwo8MP+\\n\r\ngMnTbTBOzyNAaHdIrCO9FHW6C85j3ot5Yzcr+EcBVcua+7KHU0Sgn44JNH8DisJ7\\n\r\nY63UP/1Xb4d1/QvHfxYy3WOvvRdVZ7pPo8JNX95jAoGAIe5CIg8/JizUZa7KeKUh\\n\r\n9pgDleQPkQsrHQ6/AyIwFBsLwf9THSS5V+uV9D57SfUs46Bf2U8J6N90YQSlt8iS\\n\r\naWuManFPVgT+yxDIzt6obf2mCEpOIBtQ6N4ZRh2HhQwdWTCrkzkDdGQaHG+jYL6C\\n\r\nxGPwiG2ON7OAfGIAM7eN5lECgYEAhoRLWlaOgRGnHKAWsYQvZ67CjTdDcPPuVu6v\\n\r\nfMQnNMA/7JeTwV+E205L0wfpgZ/cZKmBBlQMJlnUA3q2wfO+PTnse1mjDJU/cGtB\\n\r\n22/lJLxChlQdxGeQhGtGzUhF+hEeOhrO6WSSx7CtMRZoy6Dr6lwfMFZCdVNcBd6v\\n\r\nYOOZk3ECgYEAseUKGb6E80XTVVNziyuiVbQCsI0ZJuRfqMZ2IIDQJU9u6AnGAway\\n\r\nitqHbkGsmDT+4HUz01+1JKnnw42RdSrHdU/LaOonD+RIGqe2x800QXzqASKLdCXr\\n\r\ny7RoiFqJtkdFQykzJemA+xOXvHLgKi/MXFsU90PCD0VJKLj8vwpX78Y=\\n\r\n-----END RSA PRIVATE KEY-----\\n\r\n\"

# This below settings allows one to configure the /etc/resolv.conf nameserver resolution for all the DCAE VMs.
# -
# In the HEAT setup, it's meant to be a DNS list, as the HEAT setup deploys a DNS Server VM in addition to DNS Designate
# and this DNS Server is setup to forward request to the DNS Designate backend when it cannot resolve, hence the
# DNS_FORWARDER config here. The DCAE Boostrap requires both inputs, even though they are now similar, we have to pass
# them.
# -
# ATTENTION: Assumption is made the DNS Designate backend is configure to forward request to a public DNS (e.g. 8.8.8.8)
# -
# Put the IP of the DNS Designate backend (e.g. the OpenStack IP supporting DNS Designate)
DNS_IP: "__dns_forwarder__"
DNS_FORWARDER: "__dns_forwarder__"

# Public DNS - not used but required by the DCAE boostrap container
EXTERNAL_DNS: "__external_dns__"

# DNS domain for the DCAE VMs
DCAE_DOMAIN: "dcaeg2.onap.org"

# Proxy DNS Designate. This means DCAE will run in an instance not support Designate, and Designate will be provided by another instance.
# Set to true if you wish to use it
DNSAAS_PROXY_ENABLE: "__dnsaas_proxy_enable__"
# Provide this only if DNSAAS_PROXY_ENABLE set to true. The IP has to be the IP of one of the K8S hosts.
# e.g. http://10.195.197.164/api/multicloud-titanium_cloud/v0/pod25_RegionOne/identity/v2.0
DCAE_PROXIED_KEYSTONE_URL: "http://__k8s_ip_addr__/__dnsaas_proxied_keystone_url_path__"

# -----------------------------------------------------#
# OpenStack Config on which DNS Designate is supported #
# -----------------------------------------------------#

# If this is the same OpenStack used for the VNF or DCAE, please re-enter the values here.

DNSAAS_API_VERSION: "v3"
DNSAAS_REGION: "RegionOne"
DNSAAS_KEYSTONE_URL: "__dnsaas_keystone_url__"
DNSAAS_TENANT_ID: "__dnsaas_tenant_id__"
DNSAAS_TENANT_NAME: "__dnsaas_tenant_name__"
DNSAAS_USERNAME: "__dnsaas_username__"
DNSAAS_PASSWORD: "__dnsaas_password__"
EOF
cat ~/oom/kubernetes/config/onap-parameters.yaml


# wait for kubernetes to initialze
sleep 100
until [ $(kubectl get pods --namespace kube-system | tail -n +2 | grep -c Running) -ge 6 ]; do
    sleep 10
done

# Source the environment file:
cd ~/oom/kubernetes/oneclick/
source setenv.bash

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

cat /dockerdata-nfs/onap/dcaegen2/heat/onap_dcae.env

# Run ONAP:
cd ~/oom/kubernetes/oneclick/
./createAll.bash -n onap

# Check ONAP status:
sleep 3
kubectl get pods --all-namespaces
