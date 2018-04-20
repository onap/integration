#!/bin/bash

# kill generic_sim container
${WORKSPACE}/test/csit/scripts/so/vcpe/generic_sim/generic_sim_remove.sh
kill-instance.sh multicloud-ocata
