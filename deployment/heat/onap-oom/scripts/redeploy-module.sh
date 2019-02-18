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
helm delete $deploy --purge
/root/integration/deployment/heat/onap-oom/scripts/cleanup.sh $module
rm -rf /dockerdata-nfs/$deploy
make $module
make onap 
helm deploy $deploy local/onap -f /root/oom/kubernetes/onap/resources/environments/public-cloud.yaml -f /root/integration-override.yaml --namespace onap
