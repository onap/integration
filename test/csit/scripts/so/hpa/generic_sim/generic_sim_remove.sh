#!/bin/bash

# cp /tmp/mso-docker.json ${WORKSPACE}/test/csit/scripts/so/chef-config/mso-docker.json
rm -rf logs/*
docker stop generic_sim
docker rm generic_sim
docker rmi generic_sim
