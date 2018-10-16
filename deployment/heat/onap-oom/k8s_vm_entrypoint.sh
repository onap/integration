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

printenv

mkdir -p /opt/config
echo "__docker_version__" > /opt/config/docker_version.txt
echo "__rancher_ip_addr__" > /opt/config/rancher_ip_addr.txt
echo "__rancher_private_ip_addr__" > /opt/config/rancher_private_ip_addr.txt
HOST_IP=$(hostname -I)
echo $HOST_IP `hostname` >> /etc/hosts

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

mkdir -p /dockerdata-nfs
echo "__rancher_private_ip_addr__:/dockerdata-nfs /dockerdata-nfs nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" | tee -a /etc/fstab

# Fix virtual memory allocation for onap-log:elasticsearch:
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -p


while ! hash jq &> /dev/null; do
    apt-get -y update
    apt-get -y install linux-image-extra-$(uname -r) jq nfs-common
    sleep 10
done

# install docker 17.03
while ! hash docker &> /dev/null; do
    curl -s https://releases.rancher.com/install-docker/__docker_version__.sh | sh
    usermod -aG docker ubuntu
    sleep 10
done

while [ ! -e /dockerdata-nfs/rancher_agent_cmd.sh ]; do
    mount /dockerdata-nfs
    sleep 10
done

cd ~
cp /dockerdata-nfs/rancher_agent_cmd.sh .
sed -i "s/docker run/docker run -e CATTLE_AGENT_IP=${HOST_IP}/g" rancher_agent_cmd.sh
source rancher_agent_cmd.sh
