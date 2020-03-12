#!/usr/bin/env bash

#   COPYRIGHT NOTICE STARTS HERE
#
#   Copyright 2019 Samsung Electronics Co., Ltd.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#   COPYRIGHT NOTICE ENDS HERE

# Check all ports exposed outside of kubernetes cluster looking for non-SSL
# endpoints.
#
# Dependencies:
#     nmap
#     kubectl + config
#
# Return value: Number of discovered non-SSL ports
# Output: List of pods exposing non-SSL endpoints
#

usage() {
	cat <<EOF
Usage: $(basename $0) <k8s-namespace> [-l <list of non-SSL endpoints expected to fail this test>]
    -l: list of non-SSL endpoints expected to fail this test
EOF
	exit ${1:-0}
}

#Prerequisities commands list
REQ_APPS=(kubectl nmap awk column sort paste grep wc mktemp sed cat)

# Check for prerequisites apps
for cmd in "${REQ_APPS[@]}"; do
	if ! [ -x "$(command -v "$cmd")" ]; then
		echo "Error: command $cmd is not installed"
		exit 1
	fi
done

if [ "$#" -lt 1 ]; then
	usage 1
fi

K8S_NAMESPACE=$1
FILTERED_PORTS_LIST=$(mktemp nonssl_endpoints_XXXXXX)
XF_RAW_FILE_PATH=$(mktemp raw_filtered_nonssl_endpoints_XXXXXX)

strip_white_list() {
	if [ ! -f $XF_FILE_PATH ]; then
		echo "File not found"
		usage 1
	fi
	grep -o '^[^#]*' $XF_FILE_PATH > $XF_RAW_FILE_PATH
}

### getopts
while :
do
	case $2 in
		-h|--help|help) usage ;;
		-l) XF_FILE_PATH=$3; strip_white_list; shift ;;
		-*) usage 1 ;;
		*) break ;;
	esac
done

# Get both values on single call as this may get slow
PORTS_SVCS=`kubectl get svc --namespace=$K8S_NAMESPACE -o go-template='{{range $item := .items}}{{range $port := $item.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\t"}}{{$item.metadata.name}}{{"\n"}}{{end}}{{end}}{{end}}' | column -t | sort -n`

# Split port number and service name
PORTS=`awk '{print $1}' <<<"$PORTS_SVCS"`
SVCS=`awk '{print $2}' <<<"$PORTS_SVCS"`

# Create a list in nmap-compatible format
PORT_LIST=`tr "\\n" "," <<<"$PORTS" | sed 's/,$//'; echo ''`

# Get IP address of some cluster node (both "external-ip" and "ExternalIP" labels are matched)
K8S_NODE=`kubectl describe nodes \`kubectl get nodes | grep -v NAME | head -n 1 | awk '{print $1}'\` | grep "external-ip\|ExternalIP" | awk '{print $2}'`

# perform scan
SCAN_RESULT=`nmap $K8S_NODE -sV -p $PORT_LIST 2>/dev/null | grep \tcp`

# Concatenate scan result with service name
RESULTS=`paste <(printf %s "$SVCS") <(printf %s "$SCAN_RESULT") | column -t`

# Find all non-SSL ports
HTTP_PORTS=`grep -v ssl <<< "$RESULTS" | tee "$FILTERED_PORTS_LIST"`

# Filter out whitelisted endpoints
while IFS= read -r line; do
	# for each line we test if it is in the white list with a regular expression
	while IFS= read -r wl_line; do
		wl_name=$(echo $wl_line | awk {'print $1'})
		wl_port=$(echo $wl_line | awk {'print $2'})
		if grep -e $wl_name.*$wl_port <<< "$line"; then
			# Found in white list, exclude it
			sed -i "/^$wl_name.*$wl_port/d" $FILTERED_PORTS_LIST
		fi
	done < $XF_RAW_FILE_PATH
done < $FILTERED_PORTS_LIST

# Count them
N_FILTERED_PORTS_LIST=$(cat $FILTERED_PORTS_LIST | wc -l)
echo "------------------------------------"
echo "Nb error pod(s): $N_FILTERED_PORTS_LIST"
cat $FILTERED_PORTS_LIST
exit $N_FILTERED_PORTS_LIST
