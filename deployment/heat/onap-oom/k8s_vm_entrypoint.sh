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

mkdir -p /dockerdata-nfs
echo "__rancher_ip_addr__:/dockerdata-nfs /dockerdata-nfs nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" | tee -a /etc/fstab

apt-get -y install linux-image-extra-$(uname -r) jq nfs-common

cd ~

# install docker 17.03
curl -s https://releases.rancher.com/install-docker/17.03.sh | sh
usermod -aG docker ubuntu

# Fix virtual memory allocation for onap-log:elasticsearch:
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -p

sleep 100

while [ ! -e /dockerdata-nfs/rancher_agent_cmd.sh ]; do
    mount /dockerdata-nfs
    sleep 5
done
source /dockerdata-nfs/rancher_agent_cmd.sh

