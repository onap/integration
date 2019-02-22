#!/bin/bash

sysrepoctl -i -g /netopeer_tls_cfg/building.yang
sysrepocfg --datastore=startup --format=json --import=/netopeer_tls_cfg/building.data
/opt/dev/sysrepo/build/examples/application_changes_example building &

sed -i "s/\<name\>test\</\<name\>netconf\</g" /opt/dev/Netopeer2/server/configuration/tls_listen.xml
sysrepocfg --datastore=running --format=xml ietf-keystore --merge=/opt/dev/Netopeer2/server/configuration/load_server_certs.xml
sysrepocfg --datastore=running --format=xml ietf-netconf-server --merge=/opt/dev/Netopeer2/server/configuration/tls_listen.xml

mkdir -p /root/.ssh/
cd /root/.ssh/
cp /netopeer_tls_cfg/netopeer/known_hosts .
ssh-keygen -t rsa -N "" -f demo_rsa
pubkey=`awk '/ssh-rsa/{print $2F}' /root/.ssh/demo_rsa.pub`
echo $pubkey
#sed -i "s/\[system\-username\]/root/g;s/\[arbitrary\-key\-name\]/demo_rsa/g;s/\[key\-algorithm\]/ssh\-rsa/g" /opt/dev/Netopeer2/server/configuration/load_auth_pubkey.xml
#-e "s/\[key\-data\]/$pubkey/g" /opt/dev/Netopeer2/server/configuration/load_auth_pubkey.xml
#sysrepocfg --import=/opt/dev/Netopeer2/server/configuration/load_auth_pubkey.xml ietf-system --datastore=running
/opt/dev/Netopeer2/cli/build/netopeer2-cli  <<END
auth keys add /root/.ssh/demo_rsa.pub /root/.ssh/demo_rsa
auth keys
auth pref publickey 10
auth pref
connect
user-rpc --content /opt/dev/Netopeer2/server/configuration/load_server_key.xml
disconnect
exit
END


