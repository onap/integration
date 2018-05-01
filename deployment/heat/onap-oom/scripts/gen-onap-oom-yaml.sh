#!/bin/bash

NUM_K8S_VMS=7

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi
PARTS_DIR=$WORKSPACE/deployment/heat/onap-oom/parts

cat $PARTS_DIR/onap-oom-1.yaml

cat <<EOF
  rancher_vm:
    type: OS::Nova::Server
    properties:
      name: rancher
      image: { get_param: ubuntu_1604_image }
      flavor: { get_param: rancher_vm_flavor }
      key_name: onap_key
      networks:
      - port: { get_resource: rancher_private_port }
      user_data_format: RAW
      user_data:
        str_replace:
          template:
            get_file: rancher_vm_entrypoint.sh
          params:
            __lab_name__: { get_param: lab_name }
            __docker_proxy__: { get_param: docker_proxy }
            __apt_proxy__: { get_param: apt_proxy }
            __rancher_ip_addr__: { get_attr: [rancher_floating_ip, floating_ip_address] }
            __k8s_vm_ips__: [
EOF

for VM_NUM in $(seq $NUM_K8S_VMS); do
    K8S_VM_NAME=k8s_$VM_NUM
    cat <<EOF
              get_attr: [${K8S_VM_NAME}_floating_ip, floating_ip_address],
EOF
done

cat <<EOF
            ]
EOF

for VM_NUM in $(seq $NUM_K8S_VMS); do
    K8S_VM_NAME=k8s_$VM_NUM envsubst < $PARTS_DIR/onap-oom-2.yaml
done

cat $PARTS_DIR/onap-oom-3.yaml
