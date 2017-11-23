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
mkdir -p /opt/configmaps/settings/

cd ${WORKSPACE}/data/clone
git clone --depth 1 http://gerrit.onap.org/r/vvp/engagementmgr -b master

chmod -R 775 ${WORKSPACE}/data/

# copy settings file from tox environment infrastructure:
cp -f ${WORKSPACE}/data/clone/engagementmgr/django/vvp/settings/tox_settings.py /opt/configmaps/settings/__init__.py

# uwsgi.ini file creation
echo "[uwsgi]
http = :80
plugin = python
chdir = /srv
module = vvp.wsgi:application
master = True
pidfile = /tmp/project-master.pid
vacuum = True
max-requests = 5000
enable-threads = True
stats = 0.0.0.0:9000
stats-http = True" > /opt/configmaps/settings/uwsgi.ini

# storage.py file creation
echo "from storages.backends.s3boto import S3BotoStorage
from django.conf import settings
class S3StaticStorage(S3BotoStorage):
    custom_domain = '%s/%s' % (settings.AWS_S3_HOST, settings.STATIC_BUCKET)
    bucket_name = settings.STATIC_BUCKET
class S3MediaStorage(S3BotoStorage):
    custom_domain = '%s/%s' % (settings.AWS_S3_HOST, settings.MEDIA_BUCKET)
    bucket_name = settings.MEDIA_BUCKET" > /opt/configmaps/settings/storage.py

# envbool.py file creation
echo "import os
def envbool(key, default=False, unknown=True):
    return {'true': True, '1': True, 'false': False, '0': False,
        '': default,}.get(os.getenv(key, '').lower(), unknown)" > /opt/configmaps/settings/envbool.py

# vvp_env.list file creation
echo "# set enviroment variables
OAUTHLIB_INSECURE_TRANSPORT=1
HOST_IP=${IP}
ENVNAME=${ENVIRONMENT}
http_proxy=${http_proxy}
https_proxy=${https_proxy}
no_proxy=${no_proxy}
DJANGO_SETTINGS_MODULE=vvp.settings
# export PYTHONPATH={pwd}
SECRET_KEY=6mo22&FAKEFALEFALEFKEuq0u*4ksk^aq8lte&)yul
ENVIRONMENT=development
SERVICE_PROVIDER=ExampleProvider
PROGRAM_NAME=VVP
PROGRAM_NAME_URL_PREFIX=vvp
SERVICE_PROVIDER_DOMAIN=example-domain.com
EMAIL_HOST=localhost
EMAIL_HOST_PASSWORD=
EMAIL_HOST_USER=
EMAIL_PORT=25
PGDATABASE=icedb
PGUSER=iceuser
PGPASSWORD=Aa123456
PGHOST=localhost
PGPORT=5433
SECRET_WEBHOOK_TOKEN=AiwiFAKEFAKEFAKEmahch2zahshaGi
SECRET_GITLAB_AUTH_TOKEN=ieNgFAKEFAKE4zohvee9a
SECRET_JENKINS_PASSWORD=xaiyiFAKEFAKEqueuBu
SECRET_CMS_APP_CLIENT_ID=MHmJo0ccDhFAKEFAKEFAKEPAC6H6HAMzhCCM16
SECRET_CMS_APP_CLIENT_SECRET=nI8QFAKEEEpnw5nTs
SLACK_API_TOKEN=
S3_HOST=localhost
S3_PORT=443
AWS_ACCESS_KEY_ID=FD2FAKEFAKEFAKEVD1MWRN
AWS_SECRET_ACCESS_KEY=TKoiwxzFAKEFAKEFAKEFAKEFAKEQ27nP2lCiutEsD
STATIC_ROOT=/app/htdocs" > ${WORKSPACE}/data/environments/vvp_env.list

ifconfig

IP_ADDRESS=`ip route get 8.8.8.8 | awk '/src/{ print $7 }'`
export HOST_IP=$IP_ADDRESS
