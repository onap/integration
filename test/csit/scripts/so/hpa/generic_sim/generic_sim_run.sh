#!/bin/bash

# change SNIRO reference to the local OOF Homing instance
# cp ${WORKSPACE}/test/csit/scripts/so/chef-config/mso-docker.json /tmp

log_path=$(pwd)/logs
docker run -d -v $log_path:/generic_sim_logs -p 8081:8081 --name generic_sim generic_sim
