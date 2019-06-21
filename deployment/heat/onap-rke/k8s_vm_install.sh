#!/bin/bash -x
# Copyright 2018 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
export DEBIAN_FRONTEND=noninteractive
echo "__host_private_ip_addr__ $(hostname)" >> /etc/hosts
printenv

mkdir -p /opt/config
echo "__docker_version__" > /opt/config/docker_version.txt
echo "__nfs_ip_addr__" > /opt/config/nfs_ip_addr.txt
echo "__nfs_private_ip_addr__" > /opt/config/nfs_private_ip_addr.txt
echo "__host_private_ip_addr__" > /opt/config/host_private_ip_addr.txt
echo "__mtu__" > /opt/config/mtu.txt

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
    cat > /etc/apt/apt.conf.d/30proxy <<EOF
Acquire::http { Proxy "http://__apt_proxy__"; };
Acquire::https::Proxy "DIRECT";
EOF
fi


mkdir -p /dockerdata-nfs
echo "__nfs_private_ip_addr__:/dockerdata-nfs /dockerdata-nfs nfs noauto,noatime,fg,retry=1,x-systemd.automount,_netdev,soft,nolock,intr,tcp,actimeo=1800 0 0" | tee -a /etc/fstab

# workaround for OpenStack intermittent failure to change default apt mirrors
sed -i 's|http://archive.ubuntu.com|http://nova.clouds.archive.ubuntu.com|g' /etc/apt/sources.list

while ! hash jq &> /dev/null; do
    apt-get -y update
    # apt-get -y dist-upgrade
    apt-get -y install curl jq nfs-common
    sleep 10
done

# install docker
while ! hash docker &> /dev/null; do
    curl https://releases.rancher.com/install-docker/__docker_version__.sh | sh
    systemctl enable docker
    usermod -aG docker ubuntu
    sleep 10
done

# Enable autorestart when VM reboots
update-rc.d k8s_vm_init_serv defaults
