#!/bin/bash
sed -i '/^            #!\/bin\/bash/a\
            mkdir -p /etc/docker\
            cat > /etc/docker/daemon.json <<EOF\
            {\
              "insecure-registries" : ["192.168.31.204:5000"]\
            }\
            EOF\
            cat > /etc/apt/apt.conf.d/30proxy<<EOF\
            Acquire::http { Proxy "http://192.168.31.204:3142"; };\
            Acquire::https::Proxy "DIRECT";\
            EOF\
            apt-get -y update' $1
