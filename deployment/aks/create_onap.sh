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

set -x

BUILD_NAME=$1
KUBECONFIG=$2
OOM_BRANCH=$3
BUILD_DIR=$4
CHART_VERSION=$5
OOM_OVERRIDES=$6
MASTER_PASSWORD=$7

pushd .

cd $BUILD_DIR

export KUBECONFIG="$KUBECONFIG"
kubectl get nodes

echo "overriding default storage class for AKS"
kubectl delete sc default
sleep 1
cat > "$BUILD_DIR/tmp-sc.yaml" <<EOF
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    storageclass.beta.kubernetes.io/is-default-class: "false"
  labels:
    kubernetes.io/cluster-service: "true"
  name: default
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
volumeBindingMode: Immediate
EOF

kubectl replace -f "$BUILD_DIR/tmp-sc.yaml" --force

git clone -b "$OOM_BRANCH" http://gerrit.onap.org/r/oom --recurse-submodules

#mv requirements.yaml oom/kubernetes/onap/
cd oom/kubernetes

ls -l

helmpid=`ps -ef | grep -v grep | grep helm | awk '{print $2}'`
if [ ! -z $helmpid ]; then
  kill $helmpid
fi

helm init
echo "initializing tiller..."
sleep 3

helm serve &
echo "started helm..."
sleep 3

helm repo add local http://127.0.0.1:8879
helm repo add stable "https://kubernetes-charts.storage.googleapis.com/"

cp -R helm/plugins/ ~/.helm

make all -e SKIP_LINT=TRUE
if [ $? -ne 0 ]; then
  echo "Failed building helm charts, exiting..."
  exit 1
fi

make onap -e SKIP_LINT=TRUE
if [ $? -ne 0 ]; then
  echo "Failed building helm charts, exiting..."
  exit 1
fi

TEMPLATE_OVERRIDES="-f onap/resources/overrides/onap-all.yaml -f onap/resources/overrides/openstack.yaml --timeout 900"
if [ -f "$BUILD_DIR/integration-override.yaml" ]; then
  TEMPLATE_OVERRIDES="$TEMPLATE_OVERRIDES -f $BUILD_DIR/integration-override.yaml"
fi

helm repo remove stable
build_name=`echo "$BUILD_NAME" | tr '[:upper:]' '[:lower:]'`
helm deploy "$build_name" local/onap --version v"$CHART_VERSION" --set "global.masterPassword=$MASTER_PASSWORD" "$OOM_OVERRIDES" --namespace onap "$TEMPLATE_OVERRIDES"

kubectl get pods --namespace onap
 
popd
