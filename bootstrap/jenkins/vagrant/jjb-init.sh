#!/bin/bash

cd ~jenkins
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

