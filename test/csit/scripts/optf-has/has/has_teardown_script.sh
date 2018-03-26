#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
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
#
echo "print meaningful data before scratching everything"
docker exec -it music-db /usr/bin/cqlsh -unelson24 -pwinman123 -e 'SELECT * FROM system_schema.keyspaces'
docker exec -it music-db /usr/bin/cqlsh -unelson24 -pwinman123 -e 'SELECT * FROM admin.keyspace_master'
docker exec -it music-db /usr/bin/cqlsh -unelson24 -pwinman123 -e 'SELECT * FROM conductor.plans'

echo "optf/has scripts docker containers killing";
docker stop cond-api
docker stop cond-solv
docker stop cond-cont
docker stop cond-data
docker stop cond-resv

docker rm cond-api
docker rm cond-solv
docker rm cond-cont
docker rm cond-data
docker rm cond-resv

