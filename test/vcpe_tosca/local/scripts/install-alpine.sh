#!/bin/bash

#*******************************************************************************
# Copyright 2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#*******************************************************************************

CLI_LATEST_BINARY="https://nexus.onap.org/service/local/artifact/maven/redirect?r=releases&g=org.onap.cli&a=cli-zip&e=zip&v=LATEST"
CLI_INSTALL_DIR=/opt/oclip
CLI_ZIP=CLI.zip
CLI_BIN=/usr/bin/onap
CLI_ZIP_DIR=/opt
export OPEN_CLI_HOME=$CLI_INSTALL_DIR

#create install dir
if [ -d $CLI_INSTALL_DIR ]
then
    mv $CLI_INSTALL_DIR /opt/cli_`date +"%m-%d-%y-%H-%M-%S"`
    rm $CLI_BIN
fi

mkdir -p $CLI_INSTALL_DIR
cd $CLI_INSTALL_DIR

#Download and unzip CLI
apk update
apk add wget unzip openjdk8-jre

if [ ! -f $CLI_ZIP_DIR/$CLI_ZIP ]
    then
        wget -O $CLI_ZIP $CLI_LATEST_BINARY
    else
        mv $CLI_ZIP_DIR/$CLI_ZIP .
    fi

unzip $CLI_ZIP
if [ ! -d ./data ]; then mkdir ./data; fi
if [ ! -d ./open-cli-schema ]; then mkdir ./open-cli-schema; fi
chmod +x ./bin/oclip.sh

#Make oclip available in path
export OPEN_CLI_HOME=/opt/oclip

cd $OPEN_CLI_HOME

if [ ! -d ./data ]; then mkdir ./data; fi
if [ ! -d ./open-cli-schema ]; then mkdir ./open-cli-schema; fi

chmod +x ./bin/oclip.sh
chmod +x ./bin/oclip-rcli.sh
chmod +x ./bin/oclip-grpc-server.sh

#Make oclip available in path
ln -sf $OPEN_CLI_HOME/bin/oclip.sh /usr/bin/oclip
ln -sf $OPEN_CLI_HOME/bin/oclip.sh /usr/bin/onap
ln -sf $OPEN_CLI_HOME/bin/oclip-rcli.sh /usr/bin/roclip
ln -sf $OPEN_CLI_HOME/bin/oclip-grpc-server.sh /usr/bin/oclip-grpc

#Print the version
oclip -v

onap -v

cd -

