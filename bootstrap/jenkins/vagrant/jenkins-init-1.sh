#!/bin/bash

git config --global user.email "jenkins@localhost"
git config --global user.name "jenkins"

cd ~jenkins

cp /etc/skel/.profile .
cat > .bashrc <<EOF
alias ls='ls --color -F'
EOF

git init

git add -A
git commit -m 'Initial installation config'

mkdir -p ~/.m2
cp /vagrant/settings.xml ~/.m2
rm -f secrets/initialAdminPassword
rm -rf users/admin
rsync -avP /vagrant/jenkins/ .

git add -A
git commit -m 'Set up jenkins user'

