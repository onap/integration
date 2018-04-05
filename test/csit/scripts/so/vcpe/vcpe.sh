#!/bin/bash
set -x

# Change Endpoint to new OOF API.
GEN_SIM_PORT=":8081"
GEN_SIM_ENDPOINT="/sniro/api/v2/placement"
#cp ${WORKSPACE}/test/csit/scripts/so/chef-config/mso-docker.json /tmp

GEN_SIM_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' generic_sim`
sniroEndpoint=${GEN_SIM_IP}${GEN_SIM_PORT}${GEN_SIM_ENDPOINT}
serviceAgnosticSniroHost=${GEN_SIM_IP}${GEN_SIM_PORT}
serviceAgnosticSniroEndpoint=${GEN_SIM_ENDPOINT}

sudo apt-get install jq
# Change SNIRO reference URL to the simulator IP.
# http://sniro.api.simpledemo.openecomp.org:8080/sniro/api/v2/placement -> GEN_SIM_IP:8081/sniro/api/v2/placement..whatever the endpoint is.
val1="$sniroEndpoint" jq '.default_attributes["mso-bpmn-urn-config"].sniroEndpoint = env.val1' ${WORKSPACE}/test/csit/scripts/so/chef-config/mso-docker.json > ${WORKSPACE}/test/csit/scripts/so/chef-config/mso-docker.json
val2="$serviceAgnosticSniroHost" jq '.default_attributes["mso-bpmn-urn-config"].serviceAgnosticSniroHost = env.val2' ${WORKSPACE}/test/csit/scripts/so/chef-config/mso-docker.json > ${WORKSPACE}/test/csit/scripts/so/chef-config/mso-docker.json
val3="$serviceAgnosticSniroEndpoint" jq '.default_attributes["mso-bpmn-urn-config"].serviceAgnosticSniroEndpoint = env.val3' ${WORKSPACE}/test/csit/scripts/so/chef-config/mso-docker.json > ${WORKSPACE}/test/csit/scripts/so/chef-config/mso-docker.json

# Similarly change SNIRO auth?
# val="<auth_pass>" jq '.default_attributes["mso-bpmn-urn-config"].sniroAuth = env.val' mso-docker.json
