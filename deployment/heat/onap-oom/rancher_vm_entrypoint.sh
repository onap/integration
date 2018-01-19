#!/bin/bash -x
printenv

echo `hostname -I` `hostname` >> /etc/hosts
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "insecure-registries" : ["__docker_proxy__"]
}
EOF
cat > /etc/apt/apt.conf.d/30proxy<<EOF
Acquire::http { Proxy "http://__apt_proxy__"; };
Acquire::https::Proxy "DIRECT";
EOF
apt-get -y update
apt-get -y install docker.io
usermod -aG docker ubuntu
docker run --restart unless-stopped -d -p 8080:8080 rancher/server:v1.6.10
