#!/bin/bash
#
# Copyright 2019 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

if [ "$#" -ne 1 ]; then
   echo "Please specify module name, i.e. $0 robot"
   exit 1
fi

module=$1
deploy=dev-$1
cd /root/oom/kubernetes
echo "Deleting $deploy ..."
helm delete $deploy --purge
echo "Wait for 5 seconds before cleaning up deployment resource ..."
sleep 5
echo "Cleaning up deployment resource ..."
/root/integration/deployment/heat/onap-rke/scripts/cleanup.sh $module
echo "Wait for 5 seconds before cleaning up deployment file system ..."
sleep 5
echo "Cleaning up deployment file system ..."
rm -rf /dockerdata-nfs/$deploy
echo "Wait for 5 seconds before make $module and make onap ..."
sleep 5
echo "making $module and making onap ..."
make $module
make onap 
echo "Wait for 5 seconds before deploying $deploy ..."
sleep 5
echo "Deploying $deploy ..."
helm deploy $deploy local/onap -f /root/oom/kubernetes/onap/resources/environments/public-cloud.yaml -f /root/integration-override.yaml --namespace onap
