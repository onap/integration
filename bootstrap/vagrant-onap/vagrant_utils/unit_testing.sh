#!/bin/bash

if [[ "$debug" == "True" ]]; then
    set -o xtrace
fi

set -o errexit

TEST_SUITE=${1:-*}
TEST_CASE=${2:-*}

for file in $( ls /var/onap_tests/test_$TEST_SUITE); do
    bash ${file} $TEST_CASE
done
