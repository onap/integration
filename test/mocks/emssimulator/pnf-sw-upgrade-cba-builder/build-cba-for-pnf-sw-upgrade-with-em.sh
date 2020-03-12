#!/bin/bash

readonly SOURCE_CBA="PNF_CDS_RESTCONF"
readonly TARGET_CBA="PNF_SW_UPGRADE_WITH_EM"

if [ ! -d cds ]; then
    git clone https://gerrit.onap.org/r/ccsdk/cds cds
fi

# Lock the version of source CBA files
cd cds; git checkout -b get-cba 91b3a6477c4d5136bea02d3c1284a51b2f2ec1b1; cd $OLDPWD

rm -rf ${TARGET_CBA}

mv cds/components/model-catalog/blueprint-model/uat-blueprints/${SOURCE_CBA} ${TARGET_CBA}
rm -rf cds

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

