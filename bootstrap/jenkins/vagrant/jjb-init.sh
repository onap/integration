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
git add -A
git commit -m 'Installed plugins, restarted Jenkins' > /dev/null


mkdir -p ~/.config/jenkins_jobs
cp /vagrant/jenkins_jobs.ini ~/.config/jenkins_jobs

pip -v install --user jenkins-job-builder
pip list

jenkins-jobs update -r /vagrant/jjb

cat > .gitignore <<EOF
jobs/*/builds
jobs/*/last*
workspace/
.m2/repository/
logs/
EOF

git add -A
git commit -m 'Set up initial jobs' > /dev/null

