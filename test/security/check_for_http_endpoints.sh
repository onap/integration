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

# Check all ports exposed outside of kubernetes cluster looking for plain http
# endpoints.
#
# Dependencies:
#     nmap
#     kubectl + config
#
# Return value: Number of discovered http ports
# Output: List of pods exposing http endpoints
#

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <k8s-namespace>"
    exit 1
fi

K8S_NAMESPACE=$1

# Get both values on single call as this may get slow
PORTS_SVCS=`kubectl get svc --namespace=$K8S_NAMESPACE -o go-template='{{range $item := .items}}{{range $port := $item.spec.ports}}{{if .nodePort}}{{.nodePort}}{{"\t"}}{{$item.metadata.name}}{{"\n"}}{{end}}{{end}}{{end}}' | column -t | sort -n`

# Split port number and service name
PORTS=`awk '{print $1}' <<<"$PORTS_SVCS"`
SVCS=`awk '{print $2}' <<<"$PORTS_SVCS"`

# Create a list in nmap-compatible format
PORT_LIST=`tr "\\n" "," <<<"$PORTS" | sed 's/,$//'; echo ''`

# Get IP addres of some cluster node
K8S_NODE=`kubectl describe nodes \`kubectl get nodes | tail -n 1 | awk '{print $1}'\` | grep ExternalIP | awk '{print $2}'`

# perform scan
SCAN_RESULT=`nmap $K8S_NODE -sV -p $PORT_LIST 2>/dev/null | grep \tcp`

# Concatenate scan result with service name
RESULTS=`paste <(printf %s "$SVCS") <(printf %s "$SCAN_RESULT") | column -t`

# Find all plain http ports
HTTP_PORTS=`grep http <<< "$RESULTS" | grep -v ssl/http`

# Count them
N_HTTP=`wc -l <<<"$HTTP_PORTS"`

if [ "$N_HTTP" -gt 0 ]; then
	echo "$HTTP_PORTS"
fi

exit $N_HTTP
