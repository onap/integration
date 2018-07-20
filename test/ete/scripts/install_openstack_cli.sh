#!/bin/bash

if ! hash openstack jq
then
    echo "ERROR: Required commands not found; please install openstack CLI and jq."
    exit 2
fi

if [ -z "$OS_AUTH_URL" ] || [ -z "$OS_USERNAME" ]
then
    echo "ERROR: OpenStack environment variables not set.  Please source your OpenStack RC script first."
    exit 1
fi

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

if [ -f ${WORKSPACE}/env.properties ]; then
    source ${WORKSPACE}/env.properties
fi

if [ -z "$ONAP_WORKDIR" ]; then
    ONAP_WORKDIR=$(mktemp -d --suffix=_onap_workdir)
    echo "ONAP_WORKDIR=${ONAP_WORKDIR}" >> $WORKSPACE/env.properties
fi
echo "ONAP_WORKDIR=${ONAP_WORKDIR}"
if [ ! -d ${ONAP_WORKDIR}/demo ]; then
    git clone https://gerrit.onap.org/r/demo ${ONAP_WORKDIR}/demo
else
    pushd ${ONAP_WORKDIR}/demo
    git pull
    popd
fi
