#!/bin/bash
set -x

# Change Endpoint to new OOF API.
GEN_SIM_ENDPOINT=":8081/sniro/api/v2/placement"
cp ${WORKSPACE}/test/csit/scripts/so/chef-config/mso-docker.json /tmp

GEN_SIM_IP=`docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress}}' generic_sim`
URL=${GEN_SIM_IP}$GEN_SIM_ENDPOINT

# Change SNIRO reference URL to the simulator IP.
# http://sniro.api.simpledemo.openecomp.org:8080/sniro/api/v2/placement -> GEN_SIM_IP:8081/sniro/api/v2/placement..whatever the endpoint is.
val="$URL" jq '.default_attributes["mso-bpmn-urn-config"].sniroEndpoint = env.val' mso-docker.json

# Similarly change SNIRO auth?
# val="<auth_pass>" jq '.default_attributes["mso-bpmn-urn-config"].sniroAuth = env.val' mso-docker.json
