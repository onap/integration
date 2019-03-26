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

# allow root login
export HOME=/root
mkdir -p ~/.ssh
cp ~ubuntu/.ssh/authorized_keys ~/.ssh

export DEBIAN_FRONTEND=noninteractive
HOST_IP=$(hostname -I)
echo $HOST_IP `hostname` >> /etc/hosts
printenv

mkdir -p /opt/config
echo "__rancher_ip_addr__" > /opt/config/rancher_ip_addr.txt
echo "__k8s_vm_ips__" > /opt/config/k8s_vm_ips.txt
echo "__k8s_private_ips__" > /opt/config/k8s_private_ips.txt
echo "__public_net_id__" > /opt/config/public_net_id.txt
echo "__oam_network_cidr__" > /opt/config/oam_network_cidr.txt
echo "__oam_network_id__" > /opt/config/oam_network_id.txt
echo "__oam_subnet_id__" > /opt/config/oam_subnet_id.txt
echo "__sec_group__" > /opt/config/sec_group.txt
echo "__integration_gerrit_branch__" > /opt/config/integration_gerrit_branch.txt
echo "__integration_gerrit_refspec__" > /opt/config/integration_gerrit_refspec.txt
echo "__oom_gerrit_branch__" > /opt/config/oom_gerrit_branch.txt
echo "__oom_gerrit_refspec__" > /opt/config/oom_gerrit_refspec.txt
echo "__docker_manifest__" > /opt/config/docker_manifest.txt
echo "__docker_proxy__" > /opt/config/docker_proxy.txt
echo "__docker_version__" > /opt/config/docker_version.txt
echo "__rancher_version__" > /opt/config/rancher_version.txt
echo "__rancher_agent_version__" > /opt/config/rancher_agent_version.txt
echo "__kubectl_version__" > /opt/config/kubectl_version.txt
echo "__helm_version__" > /opt/config/helm_version.txt
echo "__helm_deploy_delay__" > /opt/config/helm_deploy_delay.txt
echo "__mtu__" > /opt/config/mtu.txt
echo "__portal_hostname__" > /opt/config/portal_hostname.txt

cat <<EOF > /opt/config/integration-override.yaml
__integration_override_yaml__
EOF
sed -i 's/\_\_portal_hostname__/__portal_hostname__/g' /opt/config/integration-override.yaml
sed -i 's/\_\_public_net_id__/__public_net_id__/g' /opt/config/integration-override.yaml
sed -i 's|\_\_oam_network_cidr__|__oam_network_cidr__|g' /opt/config/integration-override.yaml
sed -i 's/\_\_oam_network_id__/__oam_network_id__/g' /opt/config/integration-override.yaml
sed -i 's/\_\_oam_subnet_id__/__oam_subnet_id__/g' /opt/config/integration-override.yaml
sed -i 's/\_\_sec_group__/__sec_group__/g' /opt/config/integration-override.yaml
sed -i 's/\_\_rancher_ip_addr__/__rancher_ip_addr__/g' /opt/config/integration-override.yaml
sed -i 's/\_\_k8s_01_vm_ip__/__k8s_01_vm_ip__/g' /opt/config/integration-override.yaml
sed -i 's/\_\_docker_proxy__/__docker_proxy__/g' /opt/config/integration-override.yaml
cp /opt/config/integration-override.yaml /root
cat /root/integration-override.yaml

mkdir -p /etc/docker
if [ ! -z "__docker_proxy__" ]; then
    cat > /etc/docker/daemon.json <<EOF
{
  "mtu": __mtu__,
  "insecure-registries" : ["__docker_proxy__"]
}
EOF
else
    cat > /etc/docker/daemon.json <<EOF
{
  "mtu": __mtu__
}
EOF
fi
if [ ! -z "__apt_proxy__" ]; then
    cat > /etc/apt/apt.conf.d/30proxy<<EOF
Acquire::http { Proxy "http://__apt_proxy__"; };
Acquire::https::Proxy "DIRECT";
EOF
fi

# workaround for OpenStack intermittent failure to change default apt mirrors
sed -i 's|http://archive.ubuntu.com|http://nova.clouds.archive.ubuntu.com|g' /etc/apt/sources.list

while ! hash jq &> /dev/null; do
    apt-get -y update
    apt-get -y install apt-transport-https ca-certificates curl software-properties-common jq make nfs-kernel-server moreutils
    sleep 10
done

mkdir -p /dockerdata-nfs

# use RAM disk for /dockerdata-nfs for testing
if [ "__use_ramdisk__" = "true" ]; then
    echo "tmpfs /dockerdata-nfs tmpfs noatime,size=75% 1 2" >> /etc/fstab
    mount /dockerdata-nfs
fi

# update and initialize git
git config --global user.email root@rancher
git config --global user.name root@rancher
git config --global log.decorate auto

# version control the persistence volume to see what's happening
chmod 777 /dockerdata-nfs/
chown nobody:nogroup /dockerdata-nfs/
cd /dockerdata-nfs/
git init
git config user.email "root@onap"
git config user.name "root"
git add -A
git commit -m "initial commit"

# export NFS mount
echo "/dockerdata-nfs *(rw,fsid=1,async,no_root_squash,no_subtree_check)" | tee /etc/exports


exportfs -a
systemctl restart nfs-kernel-server

cd ~

# install kubectl __kubectl_version__
curl -s -LO https://storage.googleapis.com/kubernetes-release/release/v__kubectl_version__/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
mkdir ~/.kube

# install helm __helm_version__
mkdir -p helm
pushd helm
wget -q http://storage.googleapis.com/kubernetes-helm/helm-v__helm_version__-linux-amd64.tar.gz
tar -zxvf helm-v__helm_version__-linux-amd64.tar.gz
sudo cp linux-amd64/helm /usr/local/bin/helm
popd

NAMESPACE=onap

# wait for /root/.kube/config to show up
while [ ! -e /root/.kube/config ]; do
    sleep 1m
done


export KUBECONFIG=/root/.kube/config
kubectl config view



# Enable auto-completion for kubectl
echo "source <(kubectl completion bash)" >> ~/.bashrc


# wait for kubernetes to initialze
sleep 3m
until [ $(kubectl get pods --namespace kube-system | tail -n +2 | grep -c Running) -ge 6 ]; do
    sleep 1m
done


# Install using OOM


# Clone OOM:
cd ~
git clone -b __oom_gerrit_branch__ https://gerrit.onap.org/r/oom
cd oom
if [ ! -z "__oom_gerrit_refspec__" ]; then
    git fetch https://gerrit.onap.org/r/oom __oom_gerrit_refspec__
    git checkout FETCH_HEAD
fi
git checkout -b workarounds
git log -1

# Clone integration
cd ~
git clone -b __integration_gerrit_branch__ https://gerrit.onap.org/r/integration
cd integration
if [ ! -z "__integration_gerrit_refspec__" ]; then
    git fetch https://gerrit.onap.org/r/integration __integration_gerrit_refspec__
    git checkout FETCH_HEAD
fi


if [ ! -z "__docker_manifest__" ]; then
    cd version-manifest/src/main/scripts
    ./update-oom-image-versions.sh ../resources/__docker_manifest__ ~/oom/
fi

cd ~/oom
git diff
git commit -a -m "apply manifest versions"

cd ~/oom
# workaround to change onap portal cookie domain
sed -i "s/^cookie_domain.*=.*/cookie_domain = __portal_hostname__/g" ./kubernetes/portal/charts/portal-app/resources/config/deliveries/properties/ONAPPORTAL/system.properties
sed -i "s/^cookie_domain.*=.*/cookie_domain = __portal_hostname__/g" ./kubernetes/portal/charts/portal-sdk/resources/config/deliveries/properties/ONAPPORTALSDK/system.properties
git diff
git commit -a -m "set portal cookie domain"

git tag -a "deploy0" -m "initial deployment"


echo "install tiller/helm"
kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
kubectl -n kube-system rollout status deploy/tiller-deploy

# Run ONAP:
cd ~/oom/kubernetes/
helm init --client-only
helm init --upgrade
helm serve &
sleep 10
helm repo add local http://127.0.0.1:8879
helm repo list
make all
helm search -l | grep local

# install helm deploy plugin
rsync -avt ~/oom/kubernetes/helm/plugins ~/.helm/
# temporary workaround to throttle the helm deploy to alleviate startup disk contention issues
if [ ! -z "__helm_deploy_delay__" ]; then
    sed -i "/\^enabled:/a\      echo sleep __helm_deploy_delay__\n      sleep __helm_deploy_delay__" ~/.helm/plugins/deploy/deploy.sh
fi

helm deploy dev local/onap -f ~/oom/kubernetes/onap/resources/environments/public-cloud.yaml -f ~/integration-override.yaml --namespace $NAMESPACE --verbose

# re-install original helm deploy plugin
rsync -avt ~/oom/kubernetes/helm/plugins ~/.helm/

helm list



# Check ONAP status:
sleep 10
kubectl get pods --all-namespaces
kubectl get nodes
kubectl top nodes
