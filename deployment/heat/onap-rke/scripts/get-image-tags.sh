#!/bin/bash

CHECKSUMS=$(kubectl get pods -o jsonpath="{..imageID}" |tr -s '[[:space:]]' '\n' | grep '/onap' | sed 's|.*/onap|onap|' | sort -u)

for checksum in $CHECKSUMS; do
    sha256=$(echo $checksum | sed 's/.*@sha256://g')
    tag=$(curl -s https://nexus3.onap.org/service/rest/v1/search?assets.attributes.checksum.sha256=$sha256 | jq -r '.items[] | (.name + ":" + .version + "_")' | grep -v latest | sort -V | tail -1 | sed 's/_$//')
    echo ${tag:-${checksum}}
done
