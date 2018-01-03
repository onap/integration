#!/bin/bash -x

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <project-name>"
    exit 1
fi

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

MULTICLOUD_IP=$($WORKSPACE/test/ete/scripts/get-floating-ip.sh onap-multi-service)

export MULTICLOUD_PLUGIN_ENDPOINT=http://$MULTICLOUD_IP:9005/api/multicloud-titanium_cloud/v0/pod25_RegionOne

export TOKEN=$(curl -v -s -H "Content-Type: application/json" -X POST -d '{"auth": {"identity": {"methods": ["password"],"password": {"user": {"name": "demo","password": "onapdemo"}}},"scope": {"project":{"domain":{"name":"Default"},"name": "'$1'" } }}}'  $MULTICLOUD_PLUGIN_ENDPOINT/identity/v3/auth/tokens  2>&1 | grep X-Subject-Token | sed "s/^.*: //")


ZONES=$(curl -v -s  -H "Content-Type: application/json" -H "X-Auth-Token: $TOKEN" -X GET $MULTICLOUD_PLUGIN_ENDPOINT/dns-delegate/v2/zones | jq '.["zones"][] | .name' | tr -d '"' )

echo $ZONES

for ZONENAME in $ZONES; do
    echo $ZONENAME;
    export ZONEID=$(curl -v -s  -H "Content-Type: application/json" -H "X-Auth-Token: $TOKEN" -X GET $MULTICLOUD_PLUGIN_ENDPOINT/dns-delegate/v2/zones?name=$ZONENAME |sed 's/^.*"id":"\([a-zA-Z0-9-]*\)",.*$/\1/')
    curl -v -s  -H "Content-Type: application/json" -H "X-Auth-Token: $TOKEN" -X DELETE $MULTICLOUD_PLUGIN_ENDPOINT/dns-delegate/v2/zones/$ZONEID
done
