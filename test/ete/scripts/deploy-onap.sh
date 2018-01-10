#!/bin/bash -x

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <lab-name>"
    exit 1
fi

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

LAB_DIR=${WORKSPACE}/test/ete/labs/$1

if [ ! -d "$LAB_DIR" ]; then
    echo "Directory $LAB_DIR not found"
    exit 2
fi

source $WORKSPACE/test/ete/scripts/install_openstack_cli.sh


SENTINEL='Docker versions and branches'

YAML_FILE=${LAB_DIR}/onap_openstack.yaml
ENV_FILE=${LAB_DIR}/onap-openstack.env

# copy heat template to WORKSPACE
cp ${ONAP_WORKDIR}/demo/heat/ONAP/onap_openstack.yaml ${YAML_FILE}

# generate final env file
pushd ${ONAP_WORKDIR}/demo
cp ${ONAP_WORKDIR}/demo/heat/ONAP/onap_openstack.env ${LAB_DIR}/onap-openstack-demo.env
envsubst < ${LAB_DIR}/onap-openstack-template.env | sed -n "1,/${SENTINEL}/p" > ${ENV_FILE}
echo "  # Rest of the file was AUTO-GENERATED from" | tee -a ${ENV_FILE}
echo "  #" $(git config --get remote.origin.url) heat/ONAP/onap_openstack.env $(git rev-parse HEAD) | tee -a ${ENV_FILE}
popd
sed "1,/${SENTINEL}/d" ${ONAP_WORKDIR}/demo/heat/ONAP/onap_openstack.env >> ${ENV_FILE}
cat ${ENV_FILE}

# generate final heat template
# add apt proxy to heat template if applicable
if [ -x $LAB_DIR/apt-proxy.sh ]; then
    $LAB_DIR/apt-proxy.sh ${YAML_FILE}
    diff ${ONAP_WORKDIR}/demo/heat/ONAP/onap_openstack.yaml ${YAML_FILE}
fi


#exit 0

#diff ${LAB_DIR}/onap-openstack-template.env ${LAB_DIR}/onap-openstack.env


# tear down old deployment
$WORKSPACE/test/ete/scripts/teardown-onap.sh

# create new stack
STACK="ete-$(uuidgen | cut -c-8)"
echo "New Stack Name: ${STACK}"
openstack stack create -t ${YAML_FILE} -e ${LAB_DIR}/onap-openstack.env $STACK

while [ "CREATE_IN_PROGRESS" == "$(openstack stack show -c stack_status -f value $STACK)" ]; do
    sleep 20
done

STATUS=$(openstack stack show -c stack_status -f value $STACK)
echo $STATUS
if [ "CREATE_COMPLETE" != "$STATUS" ]; then
    exit 1
fi


# wait until Robot VM initializes
ROBOT_IP=$($WORKSPACE/test/ete/scripts/get-floating-ip.sh onap-robot)
echo "ROBOT_IP=${ROBOT_IP}"

if [ "" == "${ROBOT_IP}" ]; then
    exit 1
fi

ssh-keygen -R ${ROBOT_IP}

SSH_KEY=~/.ssh/onap_key

until ssh -o StrictHostKeychecking=no -i ${SSH_KEY} ubuntu@${ROBOT_IP} "docker ps | grep -q openecompete_container"
do
      sleep 2m
done
