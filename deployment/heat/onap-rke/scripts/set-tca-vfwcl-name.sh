#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo This script updates the controll loop name for vFWCL in consul
    echo "$0 <k8s_host_ip> <new_control_loop_name>"
    echo
    exit 1
fi


set -v
set -x
set -e

K8S_IP=$1
CL_NAME=$2

CONSUL_ENDPOINT=http://$K8S_IP:30270/v1/kv
TMP_DIR=$(mktemp -d)
pushd $TMP_DIR

curl -s $CONSUL_ENDPOINT/dcae-tca-analytics | jq -r '.[0].Value' | base64 --decode | jq '.' > dcae-tca-analytics.json
jq -r '.app_preferences.tca_policy' < dcae-tca-analytics.json | jq '.' > tca_policy.json
jq '.metricsPerEventName |= map( select(.eventName == "vFirewallBroadcastPackets").thresholds[].closedLoopControlName="'$CL_NAME'" )' < tca_policy.json > tca_policy_new.json
diff tca_policy.json tca_policy_new.json || true

jq  --argfile tca_policy_new tca_policy_new.json '.app_preferences.tca_policy |= ($tca_policy_new | tostring)' < dcae-tca-analytics.json > dcae-tca-analytics-new.json

jq -c '.' < dcae-tca-analytics-new.json | curl -X PUT -d @- $CONSUL_ENDPOINT/dcae-tca-analytics

popd
