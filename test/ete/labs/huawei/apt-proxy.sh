#!/bin/bash
sed -i '/^            #!\/bin\/bash/a\
            mkdir -p /etc/docker\
            cat > /etc/docker/daemon.json <<EOF\
            {\
              "insecure-registries" : ["10.145.123.23:5000"]\
            }\
            EOF\
            cat > /etc/apt/apt.conf.d/30proxy<<EOF\
            Acquire::http { Proxy "http://10.145.122.117:8000"; };\
            Acquire::https::Proxy "DIRECT";\
            EOF\
            apt-get -y update' $1
