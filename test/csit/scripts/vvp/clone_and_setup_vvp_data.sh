#!/bin/bash
#
# ============LICENSE_START=======================================================
# ONAP CLAMP
# ================================================================================
# Copyright (C) 2017 AT&T Intellectual Property. All rights
#                             reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============LICENSE_END============================================
# ===================================================================
# ECOMP is a trademark and service mark of AT&T Intellectual Property.
#

echo "This is ${WORKSPACE}/test/csit/scripts/vvp/clone_and_setup_vvp_data.sh"

# Clone vvp enviroment template
mkdir -p ${WORKSPACE}/data/environments/
mkdir -p ${WORKSPACE}/data/clone/

cd ${WORKSPACE}/data/clone
git clone --depth 1 http://gerrit.onap.org/r/vvp/engagementmgr -b master

chmod -R 775 ${WORKSPACE}/data/

# copy settings file from tox environment infrastructure:
cp -rf ${WORKSPACE}/data/clone/engagementmgr/django/vvp/settings/tox_settings.py ${WORKSPACE}/data/clone/engagementmgr/django/vvp/settings/__init__.py
echo "# set enviroment variables
DJANGO_SETTINGS_MODULE='vvp.settings.tox_settings'
# export PYTHONPATH={pwd}
SECRET_KEY='6mo22&_gtjf#wktqf1#ve^7=w6kx)uq0u*4ksk^aq8lte&)yul'
ENVIRONMENT='development'
PROGRAM_NAME_URL_PREFIX='vvp'
EMAIL_HOST='localhost'
EMAIL_HOST_PASSWORD=''
EMAIL_HOST_USER=''
EMAIL_PORT='25'
PGDATABASE='icedb'
PGUSER='iceuser'
PGPASSWORD='Aa123456'
PGHOST='localhost'
PGPORT='5433'
SECRET_WEBHOOK_TOKEN='Aiwi8se4ien0foW6eimahch2zahshaGi'
SECRET_GITLAB_AUTH_TOKEN='ieNgathapoo4zohvee9a'
SECRET_JENKINS_PASSWORD='xaiyie0wuoqueuBu'
SECRET_CMS_APP_CLIENT_ID='MHmJo0ccDheVVsIiQHZnY6LXPAC6H6HAMzhCCM16'
SECRET_CMS_APP_CLIENT_SECRET='nI8QCFrKMpnw5nTs'
SLACK_API_TOKEN=''
S3_HOST='dev-s3.d2ice.att.io'
S3_PORT='443'
AWS_ACCESS_KEY_ID='FD21HBU2KRN3UVD1MWRN'
AWS_SECRET_ACCESS_KEY='TKoiwxziUWG9cTYUknUkFGmmyuQ27nP2lCiutEsD'
STATIC_ROOT='/app/htdocs'" > ${WORKSPACE}/data/environments/vvp_env

ifconfig

IP_ADDRESS=`ip route get 8.8.8.8 | awk '/src/{ print $7 }'`
export HOST_IP=$IP_ADDRESS
