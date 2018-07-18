#!/bin/bash

IFS=$'\n'
SERVERS=$(openstack server list -f json | jq -r '.[] | .Name + " " + .Networks' )
for SERVER in $SERVERS; do
    NAME=$(echo $SERVER | cut -d ' ' -f 1)
    IP_ADDR=$(echo $SERVER | cut -d ' ' -f 3)
    echo $NAME=$IP_ADDR
    ssh -o StrictHostKeychecking=no root@$IP_ADDR "docker images -a | grep -v REPOSITORY | LC_ALL=C sort"
    echo
done
