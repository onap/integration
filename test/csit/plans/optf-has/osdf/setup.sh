#!/bin/bash
#
# -------------------------------------------------------------------------
#   Copyright (c) 2018 AT&T Intellectual Property
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# -------------------------------------------------------------------------
#

#
echo "# simulator scripts calling";
source ${WORKSPACE}/test/csit/scripts/optf-has/osdf/simulator_script.sh

# add here eventual scripts needed for optf/osdf
#
echo "# optf/osdf scripts calling";
source ${WORKSPACE}/test/csit/scripts/optf-has/osdf/osdf_script.sh

#
# add here below the start of all docker containers needed for optf/osdf CSIT testing
#
echo "# optf/osdf scripts docker containers spinoff";

#
# add here all the configuration steps eventually needed to be carried out for optf/osdf CSIT testing
#
echo "# optf/osdf configuration step";


#
# add here all ROBOT_VARIABLES settings
#
echo "# optf/osdf robot variables settings";
echo "osdf ip = ${OSDF_IP}"

ROBOT_VARIABLES="-v OSDF_HOSTNAME:http://${OSDF_IP}  -v OSDF_PORT:8699"

echo ${ROBOT_VARIABLES}



