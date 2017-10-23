#!/bin/bash

cd /opt

if [ ! -x /opt/demo.sh ]; then
    echo "Robot VM not initialized"
    exit 2
fi

if [ ! -d eteshare/logs/demo ]; then
    echo "09d8566ea45e43aa974cf447ed591d77" > /opt/config/openstack_tenant_id.txt
    echo "gary_wu" > /opt/config/openstack_username.txt
    echo $OS_PASSWORD_INPUT > /opt/config/openstack_password.txt
    /bin/bash /opt/eteshare/config/vm_config2robot.sh
    echo "test" | /opt/demo.sh init_robot
fi

/opt/ete.sh health
