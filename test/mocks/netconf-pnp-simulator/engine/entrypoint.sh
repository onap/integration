#!/bin/sh
# shellcheck disable=SC2086

#-
# ============LICENSE_START=======================================================
#  Copyright (C) 2020 Nordix Foundation.
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
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

export PATH=/opt/bin:/usr/local/bin:/usr/bin:/bin

CONFIG=/config
TLS_CONFIG=$CONFIG/tls
MODELS_CONFIG=$CONFIG/modules
KEY_PATH=/opt/etc/keystored/keys
BASE_VIRTUALENVS=$HOME/.local/share/virtualenvs

find_file() {
  local dir=$1
  shift
  for prog in "$@"; do
    if [ -f $dir/$prog ]; then
      echo -n $dir/$prog
      break
    fi
  done
}

find_executable() {
  local dir=$1
  shift
  for prog in "$@"; do
    if [ -x $dir/$prog ]; then
      echo -n $dir/$prog
      break
    fi
  done
}

configure_tls()
{
  cp $TLS_CONFIG/server_key.pem $KEY_PATH
  cp $TLS_CONFIG/server_key.pem.pub $KEY_PATH
  sysrepocfg --datastore=startup --format=xml ietf-keystore --merge=$TLS_CONFIG/load_server_certs.xml
  sysrepocfg --datastore=startup --format=xml ietf-netconf-server --merge=$TLS_CONFIG/tls_listen.xml
}

configure_modules()
{
  for dir in "$MODELS_CONFIG"/*; do
    if [ -d $dir ]; then
      model=${dir##*/}
      install_and_configure_yang_model $dir $model
      prog=$(find_executable $dir subscriber.py)
      if [ -n "$prog" ]; then
        configure_subscriber_execution $dir $model $prog
      fi
    fi
  done
}

install_and_configure_yang_model()
{
    local dir=$1
    local model=$2

    yang=$(find_file $dir $model.yang model.yang)
    sysrepoctl --install --yang=$yang
    data=$(find_file $dir startup.json startup.xml data.json data.xml)
    if [ -n "$data" ]; then
      sysrepocfg --datastore=startup --import=$data $model
    fi
}

configure_subscriber_execution()
{
  local dir=$1
  local model=$2
  local prog=$3

  PROG_PATH=$PATH
  if [ -r "$dir/requirements.txt" ]; then
    env_dir=$(create_python_venv $dir)
    PROG_PATH=$env_dir/bin:$PROG_PATH
  fi
  cat > /etc/supervisord.d/$model.conf <<EOF
[program:subs-$model]
command=$prog $model
redirect_stderr=true
autorestart=true
environment=PATH=$PROG_PATH,PYTHONPATH=/opt/lib/python3.7/site-packages,PYTHONUNBUFFERED="1"
EOF
}

create_python_venv()
{
  local dir=$1

  mkdir -p $BASE_VIRTUALENVS
  env_dir=$BASE_VIRTUALENVS/$model
  (
    python3 -m venv --system-site-packages $env_dir
    cd $env_dir
    . ./bin/activate
    pip install --upgrade pip
    pip install -r "$dir"/requirements.txt
  ) 1>&2
  echo $env_dir
}

configure_tls
configure_modules

exec /usr/local/bin/supervisord -c /etc/supervisord.conf
