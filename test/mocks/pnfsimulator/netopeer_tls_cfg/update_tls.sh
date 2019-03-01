#!/bin/bash
sleep 20
NETOPEER_CONFIG_PATH='/opt/dev/Netopeer2/server/configuration'
MOUNT_PATH='/netopeer_tls_cfg'
KEY_PATH='/usr/local/etc/keystored/keys'
SUBSCRIBE_APP_PATH='/opt/dev/sysrepo/build/examples/application_changes_example'

# This function uploads test_data and model into netopeer2 server
upload_yang_data_model()
{
  sysrepoctl -i -g $MOUNT_PATH/mynetconf.yang
  $SUBSCRIBE_APP_PATH mynetconf > /dev/null &
  sysrepocfg --datastore=running --format=json mynetconf --import=$MOUNT_PATH/mynetconf.data
}

# This function configures server/trusted certificates into Netopeer
configure_tls()
{
  sed -i "s/>test</>netconf</g" $NETOPEER_CONFIG_PATH/tls_listen.xml
  sysrepocfg --datastore=running --format=xml ietf-keystore --merge=$NETOPEER_CONFIG_PATH/load_server_certs.xml
  sysrepocfg --datastore=running --format=xml ietf-netconf-server --merge=$NETOPEER_CONFIG_PATH/tls_listen.xml
}

cp $MOUNT_PATH/test_server_key.pem $KEY_PATH
cp $MOUNT_PATH/test_server_key.pem.pub $KEY_PATH
configure_tls
upload_yang_data_model

