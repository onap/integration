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

set +e

KUBECONFIG=$1
OPENSTACK_RC=$2
CLI_NAME=$3

export KUBECONFIG=$KUBECONFIG

kubectl create configmap openstack-rc-$CLI_NAME --from-file=$OPENSTACK_RC

cat  <<EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: $CLI_NAME
spec:
  containers:
  - name: openstack-cli
    image: alpine
    volumeMounts:
    - name: openstack-rc-$CLI_NAME
      mountPath: /openstack
    command: ["/bin/sh"]
    args:
      - -c
      - apk update && \
        apk add python3 && \
        apk add py3-pip && \
        apk add python3-dev && \
        apk add gcc && \
        apk add musl-dev && \
        apk add libffi-dev && \
        apk add openssl-dev && \
        pip3 install python-openstackclient && \
        sh -c 'echo ". /openstack/openstack_rc" >> /root/.profile; while true; do sleep 60; done;'
  restartPolicy: Never
  volumes:
    - name: openstack-rc-$CLI_NAME
      configMap:
        name: openstack-rc-$CLI_NAME
        defaultMode: 0755
EOF

# TODO 
# Add better check for pod readiness
sleep 120
