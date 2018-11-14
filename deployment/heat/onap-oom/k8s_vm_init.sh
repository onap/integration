#!/bin/bash -x
# Copyright 2018 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
RANCHER_IMAGES=$(docker images | grep rancher | wc -l)
if [ $RANCHER_IMAGES -eq 0 ]; then
    while [ ! -e /dockerdata-nfs/rancher_agent_cmd.sh ]; do
        mount /dockerdata-nfs
        sleep 10
    done

    cd ~
    cp /dockerdata-nfs/rancher_agent_cmd.sh .
    sed -i "s/docker run/docker run -e CATTLE_HOST_LABELS='__host_label__=true' -e CATTLE_AGENT_IP=__host_private_ip_addr__/g" rancher_agent_cmd.sh
    source rancher_agent_cmd.sh
fi
