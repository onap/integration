#!/bin/bash

# build all jobs
cd ~jenkins
for d in jobs/docker*; do
    JOB=$(basename "$d")
    echo build "$JOB"
    java -jar jenkins-cli.jar -s http://localhost:8080/ -auth jenkins:jenkins build "$JOB"
done
