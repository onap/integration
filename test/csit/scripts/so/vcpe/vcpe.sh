#!/bin/bash
set -x

cp ${WORKSPACE}/test/csit/scripts/so/chef-config/mso-docker.json /tmp

GEN_SIM_PORT=":8081"
GEN_SIM_ENDPOINT="/sniro/api/v2/placement" # # Change Endpoint to new OOF API.
CONFIG_DIR=${WORKSPACE}/test/csit/scripts/so/chef-config/

GEN_SIM_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' generic_sim`
sniroEndpoint="http://"${GEN_SIM_IP}${GEN_SIM_PORT}${GEN_SIM_ENDPOINT}
serviceAgnosticSniroHost="http://"${GEN_SIM_IP}${GEN_SIM_PORT}
serviceAgnosticSniroEndpoint=${GEN_SIM_ENDPOINT}

sudo apt-get install jq
val1="$sniroEndpoint" jq '.default_attributes["mso-bpmn-urn-config"].sniroEndpoint = env.val1' $CONFIG_DIR/mso-docker.json > $CONFIG_DIR/temp.json
mv $CONFIG_DIR/temp.json $CONFIG_DIR/mso-docker.json

val2="$serviceAgnosticSniroHost" jq '.default_attributes["mso-bpmn-urn-config"].serviceAgnosticSniroHost = env.val2' $CONFIG_DIR/mso-docker.json > $CONFIG_DIR/temp.json
mv $CONFIG_DIR/temp.json $CONFIG_DIR/mso-docker.json

val3="$serviceAgnosticSniroEndpoint" jq '.default_attributes["mso-bpmn-urn-config"].serviceAgnosticSniroEndpoint = env.val3' $CONFIG_DIR/mso-docker.json > $CONFIG_DIR/temp.json
mv $CONFIG_DIR/temp.json $CONFIG_DIR/mso-docker.json

# val4="<auth_pass>" jq '.default_attributes["mso-bpmn-urn-config"].sniroAuth = env.val3' $CONFIG_DIR/mso-docker.json > $CONFIG_DIR/temp.json
# mv $CONFIG_DIR/temp.json $CONFIG_DIR/mso-docker.json
