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


#
# add here below the killing of all docker containers used for music CSIT testing
#
echo "dump music.log files"
ls -alF /tmp/music
ls -alFR /tmp/music
ls -alF /tmp/music/properties
cat /tmp/music/properties/music.properties
echo "===== MUSIC log =================="
docker exec music-tomcat /bin/bash -c "cat /opt/app/music/logs/MUSIC/music.log"
#cat /tmp/music/logs/MUSIC/music.log
echo "===== MUSIC error log =================="
docker exec music-tomcat /bin/bash -c "cat /opt/app/music/logs/MUSIC/error.log"
#cat /tmp/music/logs/MUSIC/error.log

echo "##########################################################";
echo "#";
echo "# music scripts docker containers killing";
echo "#";
echo "##########################################################";
docker stop music-tomcat 
docker stop music-war 
docker stop music-zk 
docker stop music-casstest
docker stop music-db

docker rm music-zk 
docker rm music-tomcat 
docker rm music-war 
docker rm music-casstest
docker rm music-db

docker network rm music-net;
sleep 5;

docker volume rm music-vol

#rm -Rf /tmp/music





