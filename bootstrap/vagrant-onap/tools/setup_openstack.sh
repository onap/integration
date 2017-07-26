#!/bin/bash

ubuntu_name=${OS_IMAGE:-"trusty-server-cloudimg-amd64-disk1"}
export OS_IMAGE=$ubuntu_name
ubuntu_glance=`openstack image list -c Name -f value | grep "$ubuntu_name"`
ubuntu_file=/tmp/ubuntu.img

sec_group_name=${OS_SEC_GROUP:-"onap-ssh-secgroup"}
export OS_SEC_GROUP=$sec_group_name
sec_group_list=`openstack security group list -c Name -f value | grep "$sec_group_name"`

if [[ -z $ubuntu_glance ]]; then
    if [ ! -f $ubuntu_file ]; then
        curl http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img -o "$ubuntu_file"
    fi

    openstack image create --disk-format raw --container-format bare --public  --file $ubuntu_file "$ubuntu_name"
fi

if [[ -z $sec_group_list ]]; then
    openstack security group create "$sec_group_name"
    openstack security group rule create --protocol tcp --remote-ip 0.0.0.0/0 --dst-port 22:22 "$sec_group_name"
fi
