#!/bin/sh

# ============LICENSE_START=======================================================
#   Copyright (C) 2019 Nordix Foundation.
# ================================================================================
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

# @author Waqas Ikram (waqas.ikram@est.tech)

touch /app/app.jar

if [ "$(ls -1 /app/ca-certificates)" ]; then
 needUpdate=FALSE
 for certificate in `ls -1 /app/ca-certificates`; do
    echo "Installing $certificate in /usr/local/share/ca-certificates"
    cp /app/ca-certificates/$certificate /usr/local/share/ca-certificates/$certificate
    needUpdate=TRUE
 done
 if [ $needUpdate = TRUE ]; then
    echo "Updating ca-certificates . . ."
    update-ca-certificates --fresh
 fi
fi 

if [ -z "$APP" ]; then
    echo "CONFIG ERROR: APP environment variable not set"
    exit 1
fi

echo "Starting $APP simulator ... "

if [ -z "${CONFIG_PATH}" ]; then
    export CONFIG_PATH=/app/config/override.yaml
fi

if [ -z "${LOG_PATH}" ]; then
    export LOG_PATH="logs/${APP}"
fi

if [ "${SSL_DEBUG}" = "log" ]; then
    export SSL_DEBUG="-Djavax.net.debug=all"
else
    export SSL_DEBUG=
fi


jvmargs="${JVM_ARGS} -Dlogs_dir=${LOG_PATH} -Dlogging.config=/app/logback-spring.xml -Dspring.config.additional-location=$CONFIG_PATH ${SSL_DEBUG} ${DISABLE_SNI}"

echo "JVM Arguments: ${jvmargs}"

java ${jvmargs} -jar app.jar
rc=$?

echo "Application exiting with status code $rc"

exit $rc
