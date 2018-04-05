#!/bin/bash

# change SNIRO reference to the local OOF Homing instance
cp ${WORKSPACE}/test/csit/scripts/so/chef-config/mso-docker.json /tmp

# Change the following if necessary.
# sed  -i -e "s%localhost:8081/%localhost:8081/%g" ${WORKSPACE}/test/csit/scripts/so/chef-config/mso-docker.json

sudo apt-get install python-pip
sudo pip install web.py
