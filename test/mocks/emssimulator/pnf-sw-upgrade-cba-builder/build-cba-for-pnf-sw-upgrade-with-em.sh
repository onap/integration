#!/bin/bash

#  ============LICENSE_START=======================================================
#  Copyright (C) 2020 Huawei Technologies Co., Ltd. All rights reserved.
#  ================================================================================
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  ============LICENSE_END=========================================================

set -euo pipefail

readonly SOURCE_CBA="PNF_CDS_RESTCONF"
readonly TARGET_CBA="PNF_SW_UPGRADE_WITH_EM"
readonly CDS_CODE_DIR="cds-codes-for-pnf-sw-upgrade"

function use_specific_commit()
{
    local commit_id="$1"
    cd ${CDS_CODE_DIR}
    local tmp_branch="get-cba-for-pnf-sw-upgrade"
    if ! git branch | grep -q "${tmp_branch}"; then
        git checkout -b ${tmp_branch} ${commit_id}
    else
        git checkout -q ${tmp_branch}
    fi
    cd ${OLDPWD}
}

if [ ! -e ${CDS_CODE_DIR} ]; then
    git clone https://gerrit.onap.org/r/ccsdk/cds ${CDS_CODE_DIR}
else
    cd ${CDS_CODE_DIR}
	code_status=`git status -s`
    if [ -n "${code_status}" ]; then
        echo "Please keep the CDS codes are not modified."
        exit 1
    fi
    cd ${OLDPWD}
fi

# Lock the version of source CBA files
use_specific_commit f4ac359d80d043a2d0e6eaf1730813b81f2c837f

if [ -e ${TARGET_CBA} -o -e ${TARGET_CBA}.zip ]; then
    echo "${TARGET_CBA} or ${TARGET_CBA}.zip has existed, please rename or delete them."
    exit 1
fi

cp -ir ${CDS_CODE_DIR}/components/model-catalog/blueprint-model/uat-blueprints/${SOURCE_CBA} ${TARGET_CBA}
cp -ir patches ${TARGET_CBA}

cd ${TARGET_CBA}

mv Definitions/PNF_CDS_RESTCONF.json Definitions/PNF_SW_UPGRADE_WITH_EM.json
mv Templates/pnf-swug-config-template.vtl Templates/pnf-swug-activate-ne-sw-template.vtl

for p in patches/*.patch; do
    patch -p1 -i $p
done

rm -rf patches

zip -r ${TARGET_CBA}.zip .

cd ${OLDPWD}

mv -i ${TARGET_CBA}/${TARGET_CBA}.zip .

