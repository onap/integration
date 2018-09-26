#!/bin/bash
#
# -------------------------------------------------------------------------
#   Copyright (c) 2015-2017 AT&T Intellectual Property
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# -------------------------------------------------------------------------
#

# put into this file local proxy settings in case they are needed on your local environment
echo "### This is ${WORKSPACE}/test/csit/scripts/optf-has/osdf/osdf_proxy_settings.sh"

echo "optf/osdf proxy settings"
if [ "$#" -eq  "1" ]; then
     echo "$1"
     cd $1
     pwd
else
     exit 1
fi

# don't remove following lines: commands can be attached here


