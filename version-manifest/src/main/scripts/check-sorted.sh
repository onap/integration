#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo This script checks the input file to verify that it is sorted
    echo "$0 <manifest.csv>"
    exit 1
fi

LC_ALL=C sort -c $1
retval=$?
if [ $retval -ne 0 ]; then
    echo
    echo "[ERROR] $1 is not properly sorted.  Please sort it with the following commands:"
    echo
    echo "  LC_ALL=C sort < $1 > $1.tmp"
    echo "  mv $1.tmp $1"
    echo
fi
exit $retval
