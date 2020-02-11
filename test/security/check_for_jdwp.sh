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

# Check all ports exposed by pods to internal network and look for
# open JDWP ports
#
# Dependencies:
#     kubectl + config
#     netcat
#
# Return value: Number of discovered JDWP ports
# Output: List of pods and exposing JDWP interface
#
usage() {
  cat <<EOF
Usage: $(basename $0) <k8s-namespace> [-l <white list file>]
    -l: jdpw white list ports file
EOF
  exit ${1:-0}
}

if [ "$#" -lt 1 ]; then
    usage
    exit 1
fi

K8S_NAMESPACE=$1
LOCAL_PORT=12543
FILTERED_PORTS_LIST=$(mktemp jdpw_ports_XXXXXX)
WL_RAW_FILE_PATH=$(mktemp raw_filtered_ports_XXXXXX)

manage_white_list() {
  # init filtered port list file
  if [ ! -f $WL_FILE_PATH ];then
   echo "File not found"
   usage
  fi
  grep -o '^[^#]*' $WL_FILE_PATH > $WL_RAW_FILE_PATH
}

### getopts
while :
do
  case $2 in
      -h|--help|help) usage;;
       -l) WL_FILE_PATH=$3;manage_white_list;shift;;
        -*) usage 1 ;;
         *) break ;;
    esac
done

list_pods() {
  kubectl get po --namespace=$K8S_NAMESPACE | grep Running | awk '{print $1}' | grep -v NAME
}

do_jdwp_handshake() {
  local ip="127.0.0.1"
  local port=$1
  local jdwp_challenge="JDWP-Handshake\n"
  local jdwp_response="JDWP-Handshake"

  # 10s timeout to avoid hangs when service doesn't answer at all
  local response=`nc -w 10 $ip $port <<<$jdwp_challenge | tr '\0' '\n'`
  local n_response_lines=`echo "$response" | wc -l`
  if [[ "$n_response_lines" -le 1 ]] && [[ $response == *"$jdwp_response"* ]]; then
  return 0
  fi

  return 1
}
# get open ports from procfs as netstat is not always available
get_open_ports_on_pod() {
  local pod=$1
  local open_ports_hex=`kubectl exec --namespace=$K8S_NAMESPACE $pod cat /proc/net/tcp 2>/dev/null| grep -v "local_address" | awk '{ print $2" "$4 }' | grep '0A$' | tr ":" " " | awk '{ print $2 }' | sort | uniq`
  for hex_port in $open_ports_hex; do
  echo $((16#$hex_port))
  done
}

N_PORTS=0

# go through all pods
for pod in `list_pods`; do
  open_ports=`get_open_ports_on_pod $pod`
  # if there is no open ports just go to next pod
  if [ -z "$open_ports" ]; then
  continue
  fi

  # let's setup a proxy and check every open port
  for port in $open_ports; do
    # run proxy
    kubectl port-forward --namespace=$K8S_NAMESPACE $pod $LOCAL_PORT:$port &>/dev/null &
    sleep 1
    proxy_pid=$!

    do_jdwp_handshake $LOCAL_PORT
    if [ $? -eq 0 ]; then
      echo $pod $port | tee $FILTERED_PORTS_LIST
      ((++N_PORTS))
    fi
    kill $proxy_pid 2>/dev/null
    wait $proxy_pid 2>/dev/null
  done
done

while IFS= read -r line; do
  # for each line we test if it is in the white list with a regular expression
  while IFS= read -r wl_line; do
   wl_name=$(echo $wl_line | awk {'print $1'})
   wl_port=$(echo $wl_line | awk {'print $2'})
   if grep -e $wl_name.*$wl_port <<< "$line";then
       # Found in white list, exclude it
       sed -i "/$line/d" $FILTERED_PORTS_LIST
   fi
  done < $WL_RAW_FILE_PATH
done < $FILTERED_PORTS_LIST

N_FILTERED_PORTS_LIST=$(cat $FILTERED_PORTS_LIST |wc -l)
echo "------------------------------------"
echo "Nb error pod(s): $N_FILTERED_PORTS_LIST"
cat $FILTERED_PORTS_LIST

exit $N_FILTERED_PORTS_LIST
