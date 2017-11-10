#!/bin/bash -x
#
# Copyright 2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

function restart_jenkins() {
    sudo systemctl restart jenkins
    sleep 1
    echo -n "Restarting jenkins"
    until $(curl --output /dev/null --silent --head --fail http://localhost:8080/login); do
	printf '.'
	sleep 3
    done
    echo
    sleep 1
}

sed -i 's|archive\.ubuntu\.com|mirrors.ocf.berkeley.edu|g' /etc/apt/sources.list

# Assume that the vagrant host is running a local Nexus proxy
echo "192.168.33.1 nexus-proxy" >> /etc/hosts


cat >> /etc/inputrc <<EOF
set show-all-if-ambiguous on
set show-all-if-unmodified on
set match-hidden-files off
set mark-symlinked-directories on
EOF


apt-get update
apt-get -y install git
git config --global user.email "jenkins@localhost"
git config --global user.name "jenkins"
apt-get -y install curl openjdk-8-jdk-headless maven unzip python-pip

# install Jenkins
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get -y install jenkins

# install docker
apt-get -y install docker.io
sudo usermod -aG docker jenkins

su -l jenkins -c "/vagrant/jenkins-init-1.sh"

restart_jenkins

su -l jenkins -c "/vagrant/jenkins-init-2.sh"

restart_jenkins

su -l jenkins -c "/vagrant/jjb-init.sh"

