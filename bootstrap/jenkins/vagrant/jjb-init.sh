#!/bin/bash

git add -A
git commit -m 'Installed plugins, restarted Jenkins'


mkdir -p ~/.config/jenkins_jobs
cp /vagrant/jenkins_jobs.ini ~/.config/jenkins_jobs

pip install --user jenkins-job-builder

jenkins-job-builder update -r /vagrant/jjb

cat > .gitignore <<EOF
jobs/*/builds
jobs/*/last*
workspace/
.m2/repository/
logs/
EOF

git add -A
git commit -m 'Set up initial jobs'


# pull 3rd party docker images
docker pull ubuntu:14.04
docker pull ubuntu:16.04
docker pull openjdk:8-jre
docker pull tomcat:8.0-jre8
docker pull jetty:9.3-jre8
docker pull frolvlad/alpine-oraclejdk8:slim
docker pull java:openjdk-8-jre
docker pull node:4.6.0
