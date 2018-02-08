#!/bin/bash -x
printenv

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
apt-get -y install docker.io
usermod -aG docker ubuntu
docker run --restart unless-stopped -d -p 8080:8080 rancher/server:v1.6.10
