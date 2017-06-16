#!/usr/bin/env python
import fileinput
import os
import subprocess

print """- project:
    name: onap-java
    jobs:
     - 'java-{project}'
    project:"""

for line in fileinput.input():
    repo = line.strip()
    isGroupRepo = subprocess.call("grep -s 'Group repo' {}/README.md > /dev/null".format(repo), shell=True) == 0
    if not isGroupRepo:
        pompaths = os.popen("./ls-top-poms.sh {}".format(repo)).readlines()
        for pompath in pompaths:
            pompath = pompath.strip()
            project = repo.replace("/", "_")
            if pompath:
                project += "_" + pompath.replace("/", "_")
            print "     - '{}':".format(project)
            print "         repo: '{}'".format(repo)
            if pompath:                
                print "         pom: '{}/pom.xml'".format(pompath)
            else:
                print "         pom: 'pom.xml'"
