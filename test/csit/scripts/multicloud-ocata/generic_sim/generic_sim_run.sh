#!/bin/bash
set -x

log_path=${WORKSPACE}/test/csit/tests/multicloud-ocata/provision
docker run -d -v $log_path:/generic_sim_logs -p 8081:8081 --name generic_sim generic_sim
