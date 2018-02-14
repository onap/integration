#!/usr/bin/env bash
###############################################################################
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
###############################################################################
SCRIPTS="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $SCRIPTS


num_bundles=$(docker exec appc_controller_container /opt/opendaylight/current/bin/client -u karaf bundle:list | tail -1 | cut -d\| -f1)
#num_failed_bundles=$(docker exec appc_controller_container /opt/opendaylight/current/bin/client -u karaf bundle:list | grep Failure | wc -l)
num_failed_bundles=$(docker exec appc_controller_container /opt/opendaylight/current/bin/client -u karaf bundle:list | grep Failure | wc -l)
failed_bundles=$(docker exec appc_controller_container /opt/opendaylight/current/bin/client -u karaf bundle:list | grep Failure)

echo "There are $num_failed_bundles failed bundles out of $num_bundles installed bundles."

if [ "$num_failed_bundles" -ge 1 ] || [ "$num_bundles" == "" ]; then
  echo "There are $num_bundles bundles with $num_failed_bundles in a failed state. "
  echo "The following bundle(s) are in a failed state: "
  echo "  $failed_bundles"
  exit 1;
fi

exit 0
