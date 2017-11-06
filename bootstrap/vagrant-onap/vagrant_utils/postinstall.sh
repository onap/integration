#!/bin/bash

if [[ "$debug" == "True" ]]; then
    set -o xtrace
fi

source /var/onap/functions

create_configuration_files
install_dev_tools
configure_bind

for serv in $@; do
    source /var/onap/${serv}
    configure_service ${serv}_serv.sh
    init_${serv}
done
