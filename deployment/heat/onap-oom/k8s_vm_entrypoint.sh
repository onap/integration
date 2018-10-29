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

export DEBIAN_FRONTEND=noninteractive
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
echo "__rancher_private_ip_addr__:/dockerdata-nfs /dockerdata-nfs nfs noauto,noatime,fg,retry=1,x-systemd.automount,_netdev,soft,nolock,intr,tcp,actimeo=1800 0 0" | tee -a /etc/fstab

# workaround for OpenStack intermittent failure to change default apt mirrors
sed -i 's|http://archive.ubuntu.com|http://nova.clouds.archive.ubuntu.com|g' /etc/apt/sources.list

while ! hash jq &> /dev/null; do
    apt-get -y update
    apt-get -y dist-upgrade
    apt-get -y install linux-image-extra-$(uname -r) apt-transport-https ca-certificates curl software-properties-common jq nfs-common
    sleep 10
done

# install docker 17.03
while ! hash docker &> /dev/null; do
    curl -s https://releases.rancher.com/install-docker/__docker_version__.sh | sh
    usermod -aG docker ubuntu
    sleep 10
done
apt-mark hold docker-ce

while [ ! -e /dockerdata-nfs/rancher_agent_cmd.sh ]; do
    mount /dockerdata-nfs
    sleep 10
done

cd ~
cp /dockerdata-nfs/rancher_agent_cmd.sh .
sed -i "s/docker run/docker run -e CATTLE_HOST_LABELS='__host_label__=true' -e CATTLE_AGENT_IP=${HOST_IP}/g" rancher_agent_cmd.sh
source rancher_agent_cmd.sh
sleep 1m

reboot
