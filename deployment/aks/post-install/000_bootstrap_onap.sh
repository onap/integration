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

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

CONF=$1

if [ -z "$CONF" ]; then
  echo "Configuration file required, exiting..."
  exit 1
fi

. $CONF

kubectl create configmap onap-bootstrap --from-file=$DIR/bootstrap/ --from-file=kubeconfig=$KUBECONFIG --from-file=onap.conf=$CONF

cat  <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: onap-bootstrap
spec:
  containers:
  - name: onap-bootstrap
    image: alpine
    env:
    - name: BUILD_DIR
      value: "/tmp/onap-bootstrap-files"
    volumeMounts:
    - name: onap-bootstrap
      mountPath: /onap-bootstrap
    command: ["/bin/sh"]
    args:
      - -c
      - apk update && \
        apk add bash && \
        apk add git && \
        apk add jq && \
        apk add curl && \
        apk add openjdk8 && \
        apk add openjdk8-jre && \
        export PATH=$PATH:/usr/lib/jvm/java-1.8-openjdk/bin && \
        curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
        chmod +x ./kubectl && \
        mv ./kubectl /usr/local/bin/kubectl && \
        cd /onap-bootstrap && \
        . onap.conf && \
        export KUBECONFIG=kubeconfig && \
        sh -c "/onap-bootstrap/bootstrap.sh"
  restartPolicy: Never
  volumes:
    - name: onap-bootstrap
      configMap:
        name: onap-bootstrap
        defaultMode: 0777
EOF

echo "Creating pod to Bootstrap ONAP with OpenStack details."
echo "This might take a while if OpenStack is still launching..."

podstatus=""
COUNTER=0

while [ "$podstatus" != "Error" ] && [ "$podstatus" != "Completed" ] && [ $COUNTER -lt 60 ]; do
  podstatus=`kubectl get pods | grep onap-bootstrap | head -1 | awk '{print $3}'`
  echo "onap-bootstrap is $podstatus"
  COUNTER=$((COUNTER +1))
  sleep 30
done

echo "onap-bootstrap pod logs available at /tmp/onap-bootstrap-log"
kubectl logs onap-bootstrap > /tmp/onap-bootstrap-log

kubectl delete pod onap-bootstrap
kubectl delete configmap onap-bootstrap

if [ "$podstatus" = "Error" ]; then
  echo "ONAP bootstrap failed!"
fi
