#!/bin/bash

source ${WORKSPACE}/test/csit/scripts/sdc/setup_sdc_for_ui_sanity.sh

BE_IP=`get-instance-ip.sh sdc-BE`
echo BE_IP=${BE_IP}


# Pass any variables required by Robot test suites in ROBOT_VARIABLES
ROBOT_VARIABLES="-v BE_IP:${BE_IP}"

