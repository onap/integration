#!/bin/bash
sed -i '/#!\/bin\/bash/a\
            # sleep up to 3 minutes to avoid disk contention\
            sleep $((RANDOM / 200))\
            mkdir -p /etc/docker\
            cat > /etc/docker/daemon.json <<EOF\
            {\
              "insecure-registries" : ["192.168.2.20:5000"]\
            }\
            EOF\
            cat > /etc/apt/apt.conf.d/30proxy<<EOF\
            Acquire::http { Proxy "http://192.168.1.51:3142"; };\
            Acquire::https::Proxy "DIRECT";\
            EOF\
            apt-get -y update' $1
