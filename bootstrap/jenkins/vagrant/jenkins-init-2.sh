#!/bin/bash -x
#
# Copyright 2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

cd ~jenkins
ln -s /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar

# Get the update center ourself
curl -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' | curl -X POST -H 'Accept: application/json' -d @- http://localhost:8080/updateCenter/byId/default/postBack

java -jar jenkins-cli.jar -s http://localhost:8080/ -auth jenkins:jenkins install-plugin git
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth jenkins:jenkins install-plugin ws-cleanup
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth jenkins:jenkins install-plugin envinject

git add -A
git commit -m 'Install initial plugins' > /dev/null

