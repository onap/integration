#!/bin/bash
set -x

cp ${WORKSPACE}/test/csit/scripts/so/chef-config/mso-docker.json /tmp

GEN_SIM_PORT=":8081"
GEN_SIM_ENDPOINT="/sniro/api/v2/placement" # # Change Endpoint to new OOF API.
CONFIG_DIR=${WORKSPACE}/test/csit/scripts/so/chef-config/

GEN_SIM_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' generic_sim`
oofEndpoint="http://"${GEN_SIM_IP}${GEN_SIM_PORT}${GEN_SIM_ENDPOINT}
serviceAgnosticOofHost="http://"${GEN_SIM_IP}${GEN_SIM_PORT}
serviceAgnosticOofEndpoint=${GEN_SIM_ENDPOINT}

sudo apt-get install jq
val1="$oofEndpoint" jq '.default_attributes["mso-bpmn-urn-config"].oofEndpoint = env.val1' $CONFIG_DIR/mso-docker.json > $CONFIG_DIR/temp.json
mv $CONFIG_DIR/temp.json $CONFIG_DIR/mso-docker.json

val2="$serviceAgnosticOofHost" jq '.default_attributes["mso-bpmn-urn-config"].serviceAgnosticOofHost = env.val2' $CONFIG_DIR/mso-docker.json > $CONFIG_DIR/temp.json
mv $CONFIG_DIR/temp.json $CONFIG_DIR/mso-docker.json

val3="$serviceAgnosticOofEndpoint" jq '.default_attributes["mso-bpmn-urn-config"].serviceAgnosticOofEndpoint = env.val3' $CONFIG_DIR/mso-docker.json > $CONFIG_DIR/temp.json
mv $CONFIG_DIR/temp.json $CONFIG_DIR/mso-docker.json

# val4="<auth_pass>" jq '.default_attributes["mso-bpmn-urn-config"].sniroAuth = env.val3' $CONFIG_DIR/mso-docker.json > $CONFIG_DIR/temp.json
# mv $CONFIG_DIR/temp.json $CONFIG_DIR/mso-docker.json
