#!/bin/bash

repos=(
"aai/aai-data" "aai/aai-config" "aai/aai-service" "aai/data-router" "aai/logging-service" "aai/model-loader" "aai/resources" "aai/rest-client" "aai/router-core" "aai/search-data-service" "aai/sparky-be" "aai/sparky-fe" "aai/test-config" "aai/traversal"
"appc" "appc/deployment"
"ci-management"
"dcae" "dcae/apod" "dcae/apod/analytics" "dcae/apod/buildtools" "dcae/apod/cdap" "dcae/collectors" "dcae/collectors/ves" "dcae/controller" "dcae/controller/analytics" "dcae/dcae-inventory" "dcae/demo" "dcae/demo/startup" "dcae/demo/startup/aaf" "dcae/demo/startup/controller" "dcae/demo/startup/message-router" "dcae/dmaapbc" "dcae/operation" "dcae/operation/utils" "dcae/orch-dispatcher" "dcae/pgaas" "dcae/utils" "dcae/utils/buildtools"
"demo"
"ecompsdkos"
"mso" "mso/chef-repo" "mso/docker-config" "mso/libs" "mso/mso-config"
"ncomp" "ncomp/cdap" "ncomp/core" "ncomp/docker" "ncomp/maven" "ncomp/openstack" "ncomp/sirius" "ncomp/sirius/manager" "ncomp/utils"
"policy/common" "policy/docker" "policy/drools-applications" "policy/drools-pdp" "policy/engine"
"portal"
"sdc" "sdc/sdc-distribution-client" "sdc/sdc-titan-cassandra" "sdc/sdc_common"
"sdnc/adaptors" "sdnc/core" "sdnc/northbound" "sdnc/oam" "sdnc/plugins"
"testsuite" "testsuite/heatbridge" "testsuite/properties" "testsuite/python-testing-utils"
"ui" "ui/dmaapbc"
"vid" "vid/asdcclient")

function git_clone_or_pull {
    local repo=$1
    local folder="./opt/$1"
    local mvn_build=$2
    if [ ! -d $folder ]; then
        git clone https://git.onap.org/$repo $folder
    fi
    pushd $folder > /dev/null
    git pull -q
    if [ -f .gitreview ]; then
        git review -s
    fi
    popd > /dev/null
}

for repo in ${repos[@]}; do
    echo "Working on $repo repository..."
    git_clone_or_pull $repo
done
