#!/bin/bash

cd ~jenkins
ln -s /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar

# Get the update center ourself
curl -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' | curl -X POST -H 'Accept: application/json' -d @- http://localhost:8080/updateCenter/byId/default/postBack

java -jar jenkins-cli.jar -s http://localhost:8080/ -auth jenkins:jenkins install-plugin git
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth jenkins:jenkins install-plugin ws-cleanup
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth jenkins:jenkins install-plugin envinject

git add -A
git commit -m 'Install initial plugins' > /dev/null

