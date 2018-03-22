#!/bin/bash

source ${WORKSPACE}/test/csit/scripts/sdc/clone_and_setup_sdc_data.sh

BE_IP=`get-instance-ip.sh sdc-BE`
echo BE_IP=${BE_IP}


# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v BE_IP:${BE_IP}"

