#!/bin/bash
# Copyright 2019 AT&T Intellectual Property. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -x 

if [ -z $VID_DNS_NAME ] || [ -z $VID_PORT ]; then
  echo "VID_DNS_NAME or VID_PORT not found. These should be environment variables."
  exit 1
fi

DATA_FILE=$BUILD_DIR"/vid_platform.json"

URI="vid/maintenance/category_parameter/platform"

cat > $DATA_FILE <<EOF
{"options":["$PLATFORM"]}
EOF

curl -i --insecure -X POST "$VID_PROTOCOL://$VID_DNS_NAME:$VID_PORT/$URI" \
  -H 'Content-Type: application/json' \
  -d @"$DATA_FILE"
echo ""
