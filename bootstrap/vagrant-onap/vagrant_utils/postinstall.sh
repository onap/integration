#!/bin/bash

if [[ "$debug" == "True" ]]; then
    set -o xtrace
fi

if [[ "$1" == "openstack" ]]; then
    source /var/onap/openstack
    deploy_openstack
    exit
fi

source /var/onap/functions

update_repos
create_configuration_files
configure_bind

for serv in $@; do
    source /var/onap/${serv}
    configure_service ${serv}_serv.sh
    init_${serv}
    echo "source /var/onap/${serv}" >> ~/.bashrc
done

echo "source /var/onap/functions" >> ~/.bashrc
