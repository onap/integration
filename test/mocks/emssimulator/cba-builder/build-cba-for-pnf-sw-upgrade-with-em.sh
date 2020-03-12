#!/bin/bash

readonly BLUEPRINT_NAME="PNF_SW_UPGRADE_WITH_EM"

git clone https://gerrit.onap.org/r/ccsdk/cds cds

# Lock the version or original CBA files
cd cds; git checkout -b get-cba 91b3a6477c4d5136bea02d3c1284a51b2f2ec1b1; cd $OLDPWD

rm -rf $BLUEPRINT_NAME

mv cds/components/model-catalog/blueprint-model/uat-blueprints/PNF_CDS_RESTCONF $BLUEPRINT_NAME
rm -rf cds

cp -r patches/* ${BLUEPRINT_NAME}

cd $BLUEPRINT_NAME

rm -rf Definitions/config-assign-pnf-mapping.json Definitions/config-deploy-pnf-mapping.json \
   	Environments/* Plans/* \
	Scripts/kotlin/RestconfConfigDeploy.kt \
	Templates/config-assign-restconf-configlet-template.vtl \
	Templates/pnf-swug-config-template.vtl \
	Tests

mv Definitions/PNF_CDS_RESTCONF.json Definitions/${BLUEPRINT_NAME}.json

sed -e "s/PNF_CDS_RESTCONF/$BLUEPRINT_NAME/" -i TOSCA-Metadata/TOSCA.meta

sed -e '23,27d' -e '51,98d' -e '189,257d' -e '326,333d' -i Definitions/${BLUEPRINT_NAME}.json
sed -e "s/PNF_CDS_RESTCONF/$BLUEPRINT_NAME/" \
	-e 's/(software-upgrade)/(software-management)/' \
	-e 's/\.swug\./.swm./' \
	-e '247,254s/configure-/activate-ne-sw-/' \
	-e '249s/config-/activate-ne-sw-/' \
	-i Definitions/${BLUEPRINT_NAME}.json

sed -e '3,21d' -i Definitions/data_types.json
sed -e 's/upgrade-software/software-management/' -i Definitions/data_types.json

sed -e 's/pnf-ipv4-address/ems-ipv4-address/' -e 's/pnf-ipaddress-aai/ems-ipaddress-aai/' -i Definitions/pnf-software-upgrade-mapping.json

sed -e 's/pnf-ipaddress-aai/ems-ipaddress-aai/' -i Definitions/resources_definition_types.json

sed -e 's/"${pnf-id}"/"%ems-id%"/' -e 's/pnf-ipv4-address/ems-ipv4-address/' -i Templates/restconf-mount-template.vtl

SW='                \"swToBeDownloaded\": [\n                  {\n                    \"swLocation\": \"http://192.168.35.96:10080/ran_du_pkg1-v2.zip\",\n                    \"swFileSize\": \"12345678\",\n                    \"swFileCompression\": \"ZIP\",\n                    \"swFileFormat\": \"binary\"\n                  }\n                ]'

sed -e '13,20s/^  //' -i Templates/pnf-swug-download-ne-sw-template.vtl
sed	-e 's/software-upgrade/software-management/' \
	-e 's/upgrade-package/pnf-software-package/' \
	-e 's/"id": "${target-software-version}"/"neIdentifier": "${pnf-id}"/' \
	-e '/"user-label"/d' \
	-e '/"uri"/d' \
	-e '/"user"/d' \
	-e '/"password"/d' \
	-e "/software-version/a\\${SW}" \
   	-i Templates/pnf-swug-download-ne-sw-template.vtl

patch -p0 Scripts/kotlin/RestconfSoftwareUpgrade.kt RestconfSoftwareUpgrade.patch
rm RestconfSoftwareUpgrade.patch

zip -r ${BLUEPRINT_NAME}.zip .
mv ${BLUEPRINT_NAME}.zip $OLDPWD

cd $OLDPWD

