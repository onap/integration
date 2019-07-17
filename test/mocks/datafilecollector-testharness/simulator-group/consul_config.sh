#!/bin/bash

# Script to configure consul with json configuration files with 'localhost' urls. This
# is needed when running the simulator as as a stand-alone app or via a dfc container in 'host' network mode. 
# Assuming the input json files hostnames for MR and DR simulators are given as 'mrsim'/'drsim'
# See available consul files in the consul dir
# The script stores a json config for 'dfc_app'<dfc-instance-id>' if arg 'app' is given.
# And for 'dfc_app'<dfc-instance-id>':dmaap' if arg 'dmaap' is given.
# Instance id shall be and integer in the range 0..5

. ../common/test_env.sh

if [ $# != 3 ]; then
	echo "Script needs three args, app|dmaap <dfc-instance-id> <json-file-path>"
	exit 1
fi

if [ $2 -lt 0 ] || [ $2 -gt $DFC_MAX_IDX ]; then
	__print_err "dfc-instance-id should be 0.."$DFC_MAX_IDX
	exit 1
fi
if ! [ -f $3 ]; then
	__print_err "json file does not extis: "$3
	exit 1
fi

if [ $1 == "app" ]; then
	appname=$DFC_APP_BASE$2
	echo "Replacing 'mrsim' with 'localhost' in json app config for consul"
	sed 's/mrsim/localhost/g' $3 > .tmp_file.json
elif [ $1 == "dmaap" ]; then
	appname=$DFC_APP_BASE$2":dmaap"
	echo "Replacing 'drsim' with 'localhost' in json dmaap config for consul"
	sed 's/drsim/localhost/g' $3 > .tmp_file.json
else
	__print_err "config type should be 'app' or 'dmaap'"
	exit 1
fi

echo "Configuring consul for " $appname " from " $3
curl -s http://127.0.0.1:${CONSUL_PORT}/v1/kv/${appname}?dc=dc1 -X PUT -H 'Accept: application/json' -H 'Content-Type: application/json' -H 'X-Requested-With: XMLHttpRequest' --data-binary "@"$tmp_file.json >/dev/null

echo "done"