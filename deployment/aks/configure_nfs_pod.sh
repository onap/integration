#!/bin/bash
# Copyright 2019 AT&T Intellectual Property. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

PRIVATE_KEY=$1
KUBECONFIG=$2
NFS_IP=$3
ADMIN_USER=$4

export KUBECONFIG=$KUBECONFIG

echo "setting up nfs on AKS nodes"
kubectl create configmap aks-key --from-file=$PRIVATE_KEY

for IPADDRESS in `kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="InternalIP")].address}'`; do 

cat  <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  generateName: configure-nfs-
spec:
  containers:
  - name: configure-nfs
    image: alpine
    env:
    - name: IP_ADDRESS
      value: "$IPADDRESS"
    - name: NFS_IP
      value: "$NFS_IP"
    volumeMounts:
    - name: aks-key
      mountPath: /aks-key
    command: ["/bin/sh"]
    args:
      - -c
      - apk update && \
        apk add openssh-client && \
        sh -c "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /aks-key/id_rsa $ADMIN_USER@\$IP_ADDRESS \"sudo apt-get update; sudo apt-get install -y -qq --no-install-recommends nfs-common; sudo rm -rf /dockerdata-nfs; sudo mkdir /dockerdata-nfs; sudo mount -t nfs \$NFS_IP:/dockerdata-nfs /dockerdata-nfs/\""
  restartPolicy: Never
  volumes:
    - name: aks-key
      configMap:
        name: aks-key
        defaultMode: 0600
EOF

done

# TODO
# Add actual pod status check here
echo "sleeping 30 seconds"
sleep 30

kubectl delete configmap aks-key
kubectl get pods | grep configure-nfs | while read line; do
  pod=`echo $line | awk '{print $1}'`
  kubectl delete pod $pod
done
