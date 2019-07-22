#!/bin/bash

###
# ============LICENSE_START=======================================================
# Simulator
# ================================================================================
# Copyright (C) 2019 Nokia. All rights reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END=========================================================
###

cat > /etc/apt/apt.conf << EOF
Acquire::http {
	No-Cache "true";
	No-Store "true";
	Pipeline-Depth "0";
};
EOF

NETOPEER_CHANGE_SAVER=netopeer-change-saver

cp /tls/* /usr/local/etc/keystored/keys/
cp /netconf/*.xml /tmp/

chmod +x /netconf/set-up-xmls.py
/netconf/set-up-xmls.py /tls ca.crt server_cert.crt server_key.pem /tmp/load_server_certs.xml /tmp/tls_listen.xml

/usr/bin/supervisord -c /etc/supervisord.conf &
sysrepoctl --install --yang=/netconf/pnf-simulator.yang --owner=netconf:nogroup --permissions=777
sysrepocfg --import=/netconf/pnf-simulator.data.xml --datastore=startup --format=xml --level=3 pnf-simulator
sysrepocfg --merge=/tmp/load_server_certs.xml --format=xml --datastore=startup ietf-keystore
sysrepocfg --merge=/tmp/tls_listen.xml --format=xml --datastore=startup ietf-netconf-server

apt-get update
apt-get install -y python3 python3-pip librdkafka-dev
pip3 install flask flask_restful
nohup python3 /netconf/yang_loader_server.py &

cd /opt/dev/sysrepo && cmake .
cd /opt/dev/sysrepo && make -j2

/bin/cp -R /$NETOPEER_CHANGE_SAVER /opt/dev/
cp /opt/dev/sysrepo/swig/libSysrepo-cpp.so /opt/dev/$NETOPEER_CHANGE_SAVER/
ln -s /opt/dev/sysrepo/build/src/libsysrepo.so /opt/dev/$NETOPEER_CHANGE_SAVER/libsysrepo.so

cd  /opt/dev/$NETOPEER_CHANGE_SAVER && cmake .
cd  /opt/dev/$NETOPEER_CHANGE_SAVER && make
/opt/dev/$NETOPEER_CHANGE_SAVER/bin/netopeer-change-saver pnf-simulator kafka1 config
