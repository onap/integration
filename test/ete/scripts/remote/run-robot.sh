#!/bin/bash -x

cd /opt

docker ps | grep -q openecompete_container
if [ ! $? -eq 0 ]; then
    echo "Robot not initialized"
    exit 2
fi

if [ ! -d eteshare/logs/demo ]; then
    echo $OS_PROJECT_ID > /opt/config/openstack_tenant_id.txt
    echo $OS_USERNAME > /opt/config/openstack_username.txt
    echo $OS_PASSWORD > /opt/config/openstack_password.txt
    /bin/bash /opt/eteshare/config/vm_config2robot.sh
    # set robot VM http server password
    echo "admin" | /opt/demo.sh init_robot
fi

/opt/ete.sh health
