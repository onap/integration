#!/bin/bash -x
#
# Copyright 2018 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

# This is meant to be run from within the Rancher VM to completely
# redeploy ONAP while reusing the existing k8s stack.
#
# This assumes that /root/integration-override.yaml is up-to-date.
#
# This script can also be used after a VM reboot, and will restart
# helm server accordingly.

export DEBIAN_FRONTEND=noninteractive

usage() {
    echo "Usage: $0 <namespace>" 1>&2;
    echo "This will completely re-deploy ONAP, and delete and re-clone oom/ and integration/ directories."
    exit 1;
}

if [ "$#" -ne 1 ]; then
   usage
fi


NS=$1
OOM_GERRIT_BRANCH=master
OOM_GERRIT_REFSPEC=refs/heads/master
INTEGRATION_GERRIT_BRANCH=master
INTEGRATION_GERRIT_REFSPEC=refs/heads/master
DOCKER_MANIFEST=""

# Verify that k8s works
if [ $(kubectl get pods --namespace kube-system | tail -n +2 | grep -c Running) -lt 6 ]; then
    echo "[ERROR] Kubernetes is not healthy; aborting"
    exit 1
fi

if [ ! -f /dockerdata-nfs/rancher_agent_cmd.sh ]; then
    cp /root/rancher_agent_cmd.sh /dockerdata-nfs
fi


kubectl delete namespace $NS
for op in secrets configmaps pvc pv services deployments statefulsets clusterrolebinding; do
    kubectl delete $op -n $NS --all
done
helm undeploy dev --purge
rm -rf /dockerdata-nfs/dev-*/


# Clone OOM:
cd ~
rm -rf oom/
git clone -b $OOM_GERRIT_BRANCH https://gerrit.onap.org/r/oom
cd oom
git fetch https://gerrit.onap.org/r/oom $OOM_GERRIT_REFSPEC
git checkout FETCH_HEAD
git checkout -b workarounds
git log -1

# Clone integration
cd ~
rm -rf integration/
git clone -b $INTEGRATION_GERRIT_BRANCH https://gerrit.onap.org/r/integration
cd integration
git fetch https://gerrit.onap.org/r/integration $INTEGRATION_GERRIT_REFSPEC
git checkout FETCH_HEAD
git checkout -b workarounds
git log -1

if [ ! -z "$DOCKER_MANIFEST" ]; then
    cd version-manifest/src/main/scripts
    ./update-oom-image-versions.sh ../resources/$DOCKER_MANIFEST ~/oom/
fi

cd ~/oom
git diff
git commit -a -m "apply manifest versions"
git tag -a "deploy0" -m "initial deployment"


# Run ONAP:
cd ~/oom/kubernetes/

if [ $(curl -s -o /dev/null -w "%{http_code}" 127.0.0.1:8879) -ne 200 ]; then
    helm init --client-only
    helm init --upgrade
    helm serve &
    sleep 10
    helm repo add local http://127.0.0.1:8879
    helm repo list
fi
make all
rsync -avt ~/oom/kubernetes/helm/plugins ~/.helm/
helm search -l | grep local
helm deploy dev local/onap -f ~/oom/kubernetes/onap/resources/environments/public-cloud.yaml -f ~/integration-override.yaml --namespace onap | ts | tee -a ~/helm-deploy.log
helm list

