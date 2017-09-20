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

sdnctl_num_tables=$(docker exec -i sdnc_db_container mysql -s -D sdnctl -u sdnctl -pgamma <<<'show tables;' 2>/dev/null | grep -v ERROR | wc -l)

appcctl_num_tables=$(docker exec -i sdnc_db_container mysql -s -D appcctl -u appcctl -pappcctl <<<'show tables;' 2>/dev/null | grep -v ERROR | wc -l)



docker exec -i sdnc_db_container mysql -s -D sdnctl -u sdnctl -pgamma <<<"show tables" 2>/dev/null | ( while read table_name; do 
export $table_name="$(docker exec -i sdnc_db_container mysql -s -D sdnctl -u sdnctl -pgamma <<<"select count(*) from $table_name" 2>/dev/null)"
done 

if [ "$sdnctl_num_tables" -ge "1" ]; then
  echo "There are $sdnctl_num_tables tables in the sdnctl database. "
else
  echo "Database sdnctl is not available."
  exit 1;
fi

if [ "$appcctl_num_tables" -ge "1" ]; then
  echo "There is $appcctl_num_tables table in the appcctl database. "
else
  echo "Database appcctl is not available."
  exit 1;
fi

#if [ "$NODE_TYPES" -eq "0" ]; then
#  echo "There is no data in table NODE_TYPES. "
#  exit 1;
#fi

#if [ "$SVC_LOGIC" -eq "0" ] ; then
#  echo "There is no data in table SVC_LOGIC. "
#  exit 1;
#fi

#if [ "$VNF_DG_MAPPING" -eq "0" ]; then
#  echo "There is no data in table VNF_DG_MAPPING. "
#  exit 1;
#fi 

echo "Expected table data is present."
exit 0 )

if [ "$?" -eq "1" ]; then
  exit 1;
fi

exit 0
