#!/bin/bash
sed -i '/#!\/bin\/bash/a\
            cat > /etc/apt/apt.conf.d/30proxy<<EOF\
            Acquire::http { Proxy "http://10.145.122.118:3142"; };\
            Acquire::https::Proxy "DIRECT";\
            EOF\
            apt-get -y update' $1
