#!/bin/bash
# Get floating IP assigned to a server name
openstack server show -c addresses -f json $1 | jq -r '.addresses' | tr -d ' ' | cut -d ',' -f 2
