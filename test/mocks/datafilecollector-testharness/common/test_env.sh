#!/bin/bash

# This env variable is only needed if the auto test scripts tests are executed in a different folder than 'auto-test' in the integration repo
# Change '<local-path>' to your path to the integration repo. In addition to the auto-test, the 'common' dir is needed if not executed in the
# integration repo.
#
#export SIM_GROUP=<local-path>/integration/test/mocks/datafilecollector-testharness/simulator-group/


# Set the images for the DFC app to use for the auto tests. Do not add the image tag.
#
# Remote image shall point to the image in the nexus repository
export DFC_REMOTE_IMAGE=nexus3.onap.org:10001/onap/org.onap.dcaegen2.collectors.datafile.datafile-app-server
#
# Local image and tag, shall point to locally built image (non-nexus path)
export DFC_LOCAL_IMAGE=onap/org.onap.dcaegen2.collectors.datafile.datafile-app-server


# Common env var for auto-test.

DFC_PORT=8100
DFC_PORT_SECURE=8433
DFC_LOGPATH="/var/log/ONAP/application.log"
DOCKER_SIM_NWNAME="dfcnet"
CONSUL_HOST="consul-server"
CONSUL_PORT=8500
CONFIG_BINDING_SERVICE="config-binding-service"
MR_PORT=2222
MR_PORT_SECURE=2223
DR_PORT=3906
DR_PORT_SECURE=3907
DRR_PORT=3908
DRR_PORT_SECURE=3909
DFC_APP_BASE="dfc_app"
DFC_MAX_NUM=5
DFC_MAX_IDX=$(($DFC_MAX_NUM - 1))
SFTP_BASE="dfc_sftp-server"
FTPS_BASE="dfc_ftpes-server-vsftpd"
FTP_MAX_NUM=5
FTP_MAX_IDX=$(($FTP_MAX_NUM - 1))
SFTP_SIMS_CONTAINER="sftp-server0:22,sftp-server1:22,sftp-server2:22,sftp-server3:22,sftp-server4:22"
FTPS_SIMS_CONTAINER="ftpes-server-vsftpd0:21,ftpes-server-vsftpd1:21,ftpes-server-vsftpd2:21,ftpes-server-vsftpd3:21,ftpes-server-vsftpd4:21"
SFTP_SIMS_LOCALHOST="localhost:1022,localhost:1023,localhost:1024,localhost:1025,localhost:1026"
FTPS_SIMS_LOCALHOST="localhost:1032,localhost:1033,localhost:1034,localhost:1035,localhost:1036"

export SFTP_SIMS=$SFTP_SIMS_CONTAINER   #This env will be set to SFTP_SIMS_LOCALHOST if auto test is executed with 'manual-app'
export FTPS_SIMS=$FTPS_SIMS_CONTAINER   #This env will be set to FTPS_SIMS_LOCALHOST if auto test is executed with 'manual-app'

export DR_REDIR_SIM="drsim_redir"       #This env will be set to 'localhost' if auto test is executed with 'manual-app'

