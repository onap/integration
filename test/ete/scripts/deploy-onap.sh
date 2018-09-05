#!/bin/bash -x

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <lab-name> [<demo repo directory>]"
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

SO_ENCRYPTION_KEY=aa3871669d893c7fb8abbcda31b88b4f
export OS_PASSWORD_ENCRYPTED=$(echo -n "$OS_PASSWORD" | openssl aes-128-ecb -e -K "$SO_ENCRYPTION_KEY" -nosalt | xxd -c 256 -p)

DEMO_DIR=${ONAP_WORKDIR}/demo
if [ "$#" -ge 2 ]; then
    DEMO_DIR=$2
fi

SENTINEL='Docker versions and branches'

mkdir -p ${LAB_DIR}/target
rsync -avt $DEMO_DIR/heat/ONAP/ ${LAB_DIR}/target/
YAML_FILE=${LAB_DIR}/target/onap_openstack.yaml
ENV_FILE=${LAB_DIR}/target/onap_openstack.env
YAML_SRC=${DEMO_DIR}/heat/ONAP/onap_openstack.yaml
ENV_SRC=${DEMO_DIR}/heat/ONAP/onap_openstack.env

# copy heat template to WORKSPACE
cp ${YAML_SRC} ${YAML_FILE}

# generate final env file
pushd ${DEMO_DIR}
envsubst < ${LAB_DIR}/onap-openstack-template.env | sed -n "1,/${SENTINEL}/p" > ${ENV_FILE}
echo "  # Rest of the file was AUTO-GENERATED from" | tee -a ${ENV_FILE}
echo "  #" $(git config --get remote.origin.url) heat/ONAP/onap_openstack.env $(git rev-parse HEAD) | tee -a ${ENV_FILE}
popd
sed "1,/${SENTINEL}/d" ${ENV_SRC} >> ${ENV_FILE}
cat ${ENV_FILE}

diff ${ENV_SRC} ${ENV_FILE}

# generate final heat template
# add apt proxy to heat template if applicable
if [ -x $LAB_DIR/apt-proxy.sh ]; then
    $LAB_DIR/apt-proxy.sh ${YAML_FILE}
    diff ${YAML_SRC} ${YAML_FILE}
fi


#exit 0

#diff ${LAB_DIR}/onap-openstack-template.env ${LAB_DIR}/onap-openstack.env


# tear down old deployment
$WORKSPACE/test/ete/scripts/teardown-onap.sh -q

# create new stack
STACK="onap-heat-$(uuidgen | cut -c-4)"
echo "New Stack Name: ${STACK}"
if ! openstack stack create -t ${YAML_FILE} -e ${ENV_FILE} $STACK; then
    exit 1
fi

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

for n in $(seq 1 10); do
    ssh -o StrictHostKeychecking=no -i ${SSH_KEY} ubuntu@${ROBOT_IP} "sudo docker ps" | grep openecompete_container
    RESULT=$?
    if [ $RESULT -eq 0 ]; then
      break
    fi
    sleep 2m
done
