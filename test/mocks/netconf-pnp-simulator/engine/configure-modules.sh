#!/bin/ash
# shellcheck disable=SC2086

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

set -eu

HERE=${0%/*}
source $HERE/common.sh

MODELS_CONFIG=$CONFIG/modules
BASE_VIRTUALENVS=$HOME/.local/share/virtualenvs

install_and_configure_yang_model()
{
    local dir=$1
    local model=$2

    log INFO Importing Yang model \"$model\"
    yang=$(find_file $dir $model.yang model.yang)
    sysrepoctl --install --yang=$yang
    data=$(find_file $dir startup.json startup.xml data.json data.xml)
    if [ -n "$data" ]; then
      log INFO Initialing Yang model \"$model\"
      sysrepocfg --datastore=startup --import=$data $model
    fi
}

configure_subscriber_execution()
{
  local dir=$1
  local model=$2
  local app=$3

  APP_PATH=$PATH
  if [ -r "$dir/requirements.txt" ]; then
    env_dir=$(create_python_venv $dir $model)
    APP_PATH=$env_dir/bin:$APP_PATH
  fi
  log INFO Preparing launching of module \"$model\" application
  cat > /etc/supervisord.d/$model.conf <<EOF
[program:subs-$model]
command=$app $model
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
redirect_stderr=true
autorestart=true
environment=PATH=$APP_PATH,PYTHONUNBUFFERED="1"
EOF
}

create_python_venv()
{
  local dir=$1
  local model=$2

  log INFO Creating virtual environment for module $model
  mkdir -p $BASE_VIRTUALENVS
  env_dir=$BASE_VIRTUALENVS/$model
  (
    virtualenv --system-site-packages $env_dir
    cd $env_dir
    # shellcheck disable=SC1091
    . ./bin/activate
    pip install --requirement "$dir"/requirements.txt
  ) 1>&2
  echo $env_dir
}

for dir in "$MODELS_CONFIG"/*; do
  if [ -d $dir ]; then
    model=${dir##*/}
    install_and_configure_yang_model $dir $model
    app="$dir/subscriber.py"
    if [ -x "$app" ]; then
      configure_subscriber_execution $dir $model $app
    fi
  fi
done
