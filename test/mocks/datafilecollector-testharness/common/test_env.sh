#!/bin/bash
#
# Modifications copyright (C) 2021 Nokia. All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

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

DFC_PORT=8100                          #Up to five dfc apps can be used, dfc_app0 will be mapped to 8100 on local machine for http, dfc_app1 mapped to 8101 etc
DFC_PORT_SECURE=8433                   #Up to five dfc apps can be used, dfc_app0 will be mapped to 8433 on local machine for hhtps, dfc_app1 mapped to 8434 etc
DFC_LOGPATH="/var/log/ONAP/application.log"  #Path the application log in the dfc container
DOCKER_SIM_NWNAME="dfcnet"             #Name of docker private network
CONFIG_BINDING_SERVICE="config-binding-service"  #Host name of CBS
CONFIG_BINDING_SERVICE_SERVICE_PORT=10000  #CBS port
MR_PORT=2222                           #MR simulator port number http
DR_PORT=3906                           #DR simulator port number http
DR_PORT_SECURE=3907                    #DR simulator port number for https
DRR_PORT=3908                          #DR Redirect simulator port number for http
DRR_PORT_SECURE=3909                   #DR Redirect simulator port number for https
DFC_APP_BASE="dfc_app"                 #Base name of the dfc containers. Instance 0 will be named dfc_app0, instance 1 will named dfc_app1 etc
DFC_MAX_NUM=5                          #Max number of dfc containers to run in paralell in auto test
DFC_MAX_IDX=$(($DFC_MAX_NUM - 1))      #Max index of the dfc containers
SFTP_BASE="dfc_sftp-server"            #Base name of the dfc_sftp-server containers. Instance 0 will be named dfc_sftp-server0, instance 1 will named dfc_sftp-server1 etc
FTPES_BASE="dfc_ftpes-server-vsftpd"    #Base name of the dfc_ftpes-server-vsftpd containers. Instance 0 will be named dfc_ftpes-server-vsftpd0, instance 1 will named dfc_ftpes-server-vsftpd1 etc
HTTP_HTTPS_BASE="dfc_http-https-server" #Base name of the dfc_http-https-server containers. Instance 0 will be named dfc_http-https-server0, instance 1 will named dfc_http-https-server1 etc
FTP_MAX_NUM=5                          #Max number of sftp and ftpes containers to run in paralell in auto test
HTTP_MAX_NUM=5                         #Max number of http/https containers to run in paralell in auto test
FTP_MAX_IDX=$(($FTP_MAX_NUM - 1))      #Max index of sftp and ftpes containers
HTTP_MAX_IDX=$(($HTTP_MAX_NUM - 1))    #Max index of http/https containers

#List of sftp server name and port number, used by MR sim to produce file urls. Theses server names and ports are used when running dfc and the simulators in a private docker network
SFTP_SIMS_CONTAINER="sftp-server0:22,sftp-server1:22,sftp-server2:22,sftp-server3:22,sftp-server4:22"

#List of sftp server name and port number, used by MR sim to produce file urls. Theses server names and ports are used when running dfc and the simulators in a private docker network
FTPES_SIMS_CONTAINER="ftpes-server-vsftpd0:21,ftpes-server-vsftpd1:21,ftpes-server-vsftpd2:21,ftpes-server-vsftpd3:21,ftpes-server-vsftpd4:21"

#List of http/https/https with no authorization/with jwt token server name and port number, used by MR sim to produce file urls. Theses server names and ports are used when running dfc and the simulators in a private docker network
HTTP_SIMS_CONTAINER="http-https-server0:80,http-https-server1:80,http-https-server2:80,http-https-server3:80,http-https-server4:80"
HTTP_JWT_SIMS_CONTAINER="http-https-server0:32000,http-https-server1:32000,http-https-server2:32000,http-https-server3:32000,http-https-server4:32000"
HTTPS_SIMS_CONTAINER="http-https-server0:443,http-https-server1:443,http-https-server2:443,http-https-server3:443,http-https-server4:443"
HTTPS_SIMS_NO_AUTH_CONTAINER="http-https-server0:8080,http-https-server1:8080,http-https-server2:8080,http-https-server3:8080,http-https-server4:8080"
HTTPS_JWT_SIMS_CONTAINER="http-https-server0:32100,http-https-server1:32100,http-https-server2:32100,http-https-server3:32100,http-https-server4:32100"

#List of sftp server name and port number, used by MR sim to produce file urls. Theses server names and ports are used when running dfc as stand along app and the simulators in a private docker network
SFTP_SIMS_LOCALHOST="localhost:1022,localhost:1023,localhost:1024,localhost:1025,localhost:1026"

#List of ftpes server name and port number, used by MR sim to produce file urls. Theses server names and ports are used when running dfc as stand along app and the simulators in a private docker network
FTPES_SIMS_LOCALHOST="localhost:1032,localhost:1033,localhost:1034,localhost:1035,localhost:1036"

#List of http/https/https with no authorization/with jwt token server name and port number, used by MR sim to produce file urls. Theses server names and ports are used when running dfc as stand along app and the simulators in a private docker network
HTTP_SIMS_LOCALHOST="localhost:81,localhost:82,localhost:83,localhost:84,localhost:85"
HTTP_JWT_SIMS_LOCALHOST="localhost:32001,localhost:32002,localhost:32003,localhost:32004,localhost:32005"
HTTPS_SIMS_LOCALHOST="localhost:444,localhost:445,localhost:446,localhost:447,localhost:448"
HTTPS_SIMS_NO_AUTH_LOCALHOST="localhost:8081,localhost:8082,localhost:8083,localhost:8084,localhost:8085"
HTTPS_JWT_SIMS_LOCALHOST="localhost:32101,localhost:32102,localhost:32103,localhost:32104,localhost:32105"

export SFTP_SIMS=$SFTP_SIMS_CONTAINER   #This env will be set to SFTP_SIMS_LOCALHOST if auto test is executed with 'manual-app'
export FTPES_SIMS=$FTPES_SIMS_CONTAINER   #This env will be set to FTPES_SIMS_LOCALHOST if auto test is executed with 'manual-app'
export HTTP_SIMS=$HTTP_SIMS_CONTAINER   #This env will be set to HTTP_SIMS_LOCALHOST if auto test is executed with 'manual-app'
export HTTP_JWT_SIMS=$HTTP_JWT_SIMS_CONTAINER #This env will be set to HTTP_JWT_SIMS_LOCALHOST if auto test is executed with 'manual-app'
export HTTPS_SIMS=$HTTPS_SIMS_CONTAINER   #This env will be set to HTTPS_SIMS_LOCALHOST if auto test is executed with 'manual-app'
export HTTPS_SIMS_NO_AUTH=$HTTPS_SIMS_NO_AUTH_CONTAINER   #This env will be set to HTTPS_SIMS_NO_AUTH_LOCALHOST if auto test is executed with 'manual-app'
export HTTPS_JWT_SIMS=$HTTPS_JWT_SIMS_CONTAINER   #This env will be set to HTTPS_JWT_SIMS_LOCALHOST if auto test is executed with 'manual-app'

#Host name of the DR redirect simulator
export DR_REDIR_SIM="drsim_redir"       #This env will be set to 'localhost' if auto test is executed with arg 'manual-app'

