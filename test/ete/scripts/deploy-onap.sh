#!/bin/bash

if [ -z "$OS_AUTH_URL" ] || [ -z "$OS_USERNAME" ]
then
    echo "ERROR: OpenStack environment variables not set.  Please source your OpenStack RC script first."
    exit 1
fi


if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi



# Assume that if ROBOT_VENV is set, we don't need to reinstall robot
if [ -f ${WORKSPACE}/env.properties ]; then
    source ${WORKSPACE}/env.properties
fi

if [ ! -z "$ONAP_VENV" ] && [ -f "$ONAP_VENV/bin/activate" ]; then
    source ${ONAP_VENV}/bin/activate
else
    ONAP_VENV=$(mktemp -d --suffix=_onap_venv)
    virtualenv ${ONAP_VENV}
    source ${ONAP_VENV}/bin/activate
    
    pip install --upgrade pip
    pip install --upgrade python-openstackclient python-heatclient
    
    echo "ONAP_VENV=${ONAP_VENV}" >> $WORKSPACE/env.properties
fi
echo "ONAP_VENV=${ONAP_VENV}"

if [ -z "$ONAP_WORKDIR" ]; then
    ONAP_WORKDIR=$(mktemp -d --suffix=_onap_workdir)
    echo "ONAP_WORKDIR=${ONAP_WORKDIR}" >> $WORKSPACE/env.properties
fi
echo "ONAP_WORKDIR=${ONAP_WORKDIR}"
if [ ! -d ${ONAP_WORKDIR}/demo ]; then
    git clone http://gerrit.onap.org/r/demo ${ONAP_WORKDIR}/demo
else
    pushd ${ONAP_WORKDIR}/demo
    git pull
    popd
fi



STACK="ete-$(uuidgen | cut -c-8)"
echo "Stack Name: ${STACK}"
openstack stack create -t ${ONAP_WORKDIR}/demo/heat/ONAP/onap_openstack.yaml -e ${WORKSPACE}/test/ete/labs/windriver/onap.env $STACK

