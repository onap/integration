#!/bin/bash -x
# Get floating IP assigned to a server name

PORT_ID=$(openstack server show -f json $1 | python -c 'import sys, json; print json.load(sys.stdin)["wrs-if:nics"][0]["nic1"]["port_id"]')
FLOATING_IP=$(openstack floating ip list -f json --port $PORT_ID | python -c 'import sys, json; print json.load(sys.stdin)[0]["Floating IP Address"]')
echo $FLOATING_IP
