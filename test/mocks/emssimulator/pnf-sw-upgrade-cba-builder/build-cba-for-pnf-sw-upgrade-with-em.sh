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

readonly SOURCE_CBA="PNF_CDS_RESTCONF"
readonly TARGET_CBA="PNF_SW_UPGRADE_WITH_EM"
readonly CDS_CODE_DIR=`mktemp -d -p .`

git clone https://gerrit.onap.org/r/ccsdk/cds ${CDS_CODE_DIR}

# Lock the version of source CBA files
cd ${CDS_CODE_DIR}; git checkout -b get-cba-for-pnf-sw-upgrade 91b3a6477c4d5136bea02d3c1284a51b2f2ec1b1; cd $OLDPWD

if [ -d ${TARGET_CBA} ]; then
    BACKUP_DIR="bak-${TARGET_CBA}-${RANDOM}"
    mv ${TARGET_CBA} ${BACKUP_DIR}
    echo "Backup ${TARGET_CBA} to ${BACKUP_DIR}"
fi

mv ${CDS_CODE_DIR}/components/model-catalog/blueprint-model/uat-blueprints/${SOURCE_CBA} ${TARGET_CBA}
rm -rf ${CDS_CODE_DIR}

cp -r patches/* ${TARGET_CBA}

cd ${TARGET_CBA}

rm -rf Definitions/config-assign-pnf-mapping.json Definitions/config-deploy-pnf-mapping.json \
    Environments/* Plans/* \
    Scripts/kotlin/RestconfConfigDeploy.kt \
    Templates/config-assign-restconf-configlet-template.vtl \
    Tests

sed -e "s/${SOURCE_CBA}/${TARGET_CBA}/" -i TOSCA-Metadata/TOSCA.meta

mv Definitions/${SOURCE_CBA}.json Definitions/${TARGET_CBA}.json
sed -e '23,27d' -e '51,98d' -e '189,257d' -e '326,333d' -i Definitions/${TARGET_CBA}.json
sed -e "s/${SOURCE_CBA}/${TARGET_CBA}/" \
    -e 's/(software-upgrade)/(software-management)/' \
    -e 's/\.swug\./.swm./' \
    -e '247,254s/configure-/activate-ne-sw-/' \
    -e '249s/config-/activate-ne-sw-/' \
    -i Definitions/${TARGET_CBA}.json

sed -e '3,21d' -i Definitions/data_types.json
sed -e 's/upgrade-software/software-management/' -i Definitions/data_types.json

sed -e 's/pnf-ipv4-address/ems-ipv4-address/' -e 's/pnf-ipaddress-aai/ems-ipaddress-aai/' -i Definitions/pnf-software-upgrade-mapping.json

sed -e 's/pnf-ipaddress-aai/ems-ipaddress-aai/' -i Definitions/resources_definition_types.json

sed -e 's/"${pnf-id}"/"%ems-id%"/' -e 's/pnf-ipv4-address/ems-ipv4-address/' -i Templates/restconf-mount-template.vtl

readonly SW_DOWNLOAD='                \"swToBeDownloaded\": [\n                  {\n                    \"swLocation\": \"http://192.168.35.96:10080/ran_du_pkg1-v2.zip\",\n                    \"swFileSize\": \"12345678\",\n                    \"swFileCompression\": \"ZIP\",\n                    \"swFileFormat\": \"binary\"\n                  }\n                ]'
sed -e '13,20s/^  //' -i Templates/pnf-swug-download-ne-sw-template.vtl
sed -e 's/software-upgrade/software-management/' \
    -e 's/upgrade-package/pnf-software-package/' \
    -e 's/"id": "${target-software-version}"/"neIdentifier": "${pnf-id}"/' \
    -e '/"user-label"/d' \
    -e '/"uri"/d' \
    -e '/"user"/d' \
    -e '/"password"/d' \
    -e "/software-version/a\\${SW_DOWNLOAD}" \
    -i Templates/pnf-swug-download-ne-sw-template.vtl

readonly SW_ACTIVATE='                "swVersionToBeActivated": "${target-software-version}"'
mv Templates/pnf-swug-config-template.vtl Templates/pnf-swug-activate-ne-sw-template.vtl
sed -e 's/software-upgrade/software-management/' \
    -e 's/upgrade-package/pnf-software-package/' \
    -e 's/"id": "%id%"/"neIdentifier": "${pnf-id}"/' \
    -e '/"action"/s/$/,/' \
    -e "/action/a\\${SW_ACTIVATE}" \
    -i Templates/pnf-swug-activate-ne-sw-template.vtl


patch -p0 Scripts/kotlin/RestconfSoftwareUpgrade.kt RestconfSoftwareUpgrade.patch
rm RestconfSoftwareUpgrade.patch

zip -r ${TARGET_CBA}.zip .
mv ${TARGET_CBA}.zip $OLDPWD

cd $OLDPWD

