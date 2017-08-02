#!/bin/bash

run=false

while getopts "ydh" OPTION; do
    case $OPTION in
        y)
            run=true
            ;;
        d)
            set -o xtrace
            ;;
        h)
            echo "Usage: unit_testing.sh [-y] [-d] [-h]"
            echo "Optional arguments:"
            echo "    -y    Skips warning prompt."
            echo "    -d    Shows debugging output."
            echo "    -h    Shows help about this program."
            exit 0
            ;;
    esac
done

if [ "$run" = false ] ; then
    while true; do
        echo "Warning: This test script will delete the contents of your /opt folder."
        read -p "Would you like to continue? [y]es/[n]o" yn
        case $yn in
            [Yy]*)
                break
                ;;
            [Nn]*)
                exit
                ;;
        esac
    done
fi

rm -rf /opt/
rm -rf /root/.m2/

set -o errexit

TEST_SUITE=${1:-*}
TEST_CASE=${2:-*}

for file in $( ls /var/onap_tests/test_$TEST_SUITE); do
    bash ${file} $TEST_CASE
done
