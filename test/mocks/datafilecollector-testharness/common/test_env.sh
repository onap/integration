#!/bin/bash

# This env variable is only needed if the auto test scripts tests are executed in a different folder than 'auto-test' in the integration repo 
# Change '<local-path>' to your path to the integration repo. In addition to the auto-test, the 'common' dir is needed if not executed in the
# integration repo.
#
#export SIM_GROUP=<local-path>/integration/test/mocks/datafilecollector-testharness/simulator-group/


# Set the images for the DFC app to use for the auto tests. Do not add the image tag.
#
# Remote image shall point to the image in the nexus repository
export DFC_REMOTE_IMAGE=nexus3.onap.org:10001/onap/org.onap.dcaegen2.collectors.datafile.datafile-app-server
#
# Local image and tag, shall point to locally built image (non-nexus path)
export DFC_LOCAL_IMAGE=onap/org.onap.dcaegen2.collectors.datafile.datafile-app-server


