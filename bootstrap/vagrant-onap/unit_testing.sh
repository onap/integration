#!/bin/bash

set -o xtrace

rm -rf /opt/
rm -rf /root/.m2/

set -o errexit

TEST_SUITE=${1:-*}
TEST_CASE=${2:-*}

for file in $( ls /var/onap_tests/test_$TEST_SUITE); do
    bash ${file} $TEST_CASE
done
