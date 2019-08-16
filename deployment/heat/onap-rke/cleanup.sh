#!/bin/bash

IFS='
'

if [ -z $1 ]; then
	echo "ONAP component name missing"
	echo "Usage: ./cleanup.sh onap_component_name"
	exit 1
fi

( cd scripts; ./cleanup.sh $1 onap dev )
