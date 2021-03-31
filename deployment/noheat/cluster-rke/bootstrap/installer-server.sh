#!/bin/sh

# Prerequisites
sudo apt-get update
sudo apt-get install --yes software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt-get install --yes git ansible

# Dependencies
git clone https://git.onap.org/oom/offline-installer

# Main
HOSTS="${HOME}/hosts.yml"

cd offline-installer
cp config/application_configuration.yml application
sed -i'' 's|/opt|~|' application/application_configuration.yml # ensure write permission for regular user

cd ansible
mv "$HOSTS" inventory
ansible-playbook -i inventory/hosts.yml -e @application/application_configuration.yml rke.yml
