#!/bin/bash

# This script prepares the runtime environment
# for running vCPE python scripts on Ubuntu 16.04,
# 18.04 and on Centos/Rhel 7.6.

if command -v apt-get > /dev/null; 
then
    apt-get update
    apt-get -y install python gcc python-dev;
fi
if command -v yum > /dev/null;
then
    yum -y install python-devel gcc;
fi

curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py
pip install -I \
    ipaddress \
    pyyaml \
    mysql-connector-python \
    progressbar2 \
    python-novaclient \
    python-openstackclient \
    python-heatclient \
    kubernetes \
    netaddr
