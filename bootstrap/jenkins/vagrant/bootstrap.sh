#!/bin/sh

sed -i 's|archive\.ubuntu\.com|mirrors.ocf.berkeley.edu|g' /etc/apt/sources.list

echo "192.168.33.1 nexus-proxy" >> /etc/hosts


cat >> /etc/inputrc <<EOF
set show-all-if-ambiguous on
set show-all-if-unmodified on
set match-hidden-files off
set mark-symlinked-directories on
EOF


apt-get update
apt-get -y install git
git config --global user.email "gary.i.wu@huawei.com"
git config --global user.name "Gary Wu"
apt-get -y install curl openjdk-8-jdk maven unzip

# install Jenkins
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get -y install jenkins jenkins-job-builder python-pip

apt-get -y install docker.io
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins

su -l jenkins -c "/vagrant/jenkins-init-1.sh"

sudo systemctl restart jenkins
sleep 5

su -l jenkins -c "/vagrant/jenkins-init-2.sh"

sudo systemctl restart jenkins
sleep 5

su -l jenkins -c "/vagrant/jjb-init.sh"

