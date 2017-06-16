#!/bin/bash

# vim: ts=4 sw=4 sts=4 et :

DOCKER_REPOSITORIES="nexus3.onap.org:10001 \
                   nexus3.onap.org:10002 \
                   nexus3.onap.org:10003 \
                   nexus3.onap.org:10004"

for DOCKER_REPOSITORY in $DOCKER_REPOSITORIES;
do
    echo $DOCKER_REPOSITORY
    docker login $DOCKER_REPOSITORY -u "anonymous" -p "anonymous"
done
