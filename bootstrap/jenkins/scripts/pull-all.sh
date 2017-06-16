#!/bin/sh
while read p; do
    echo $p
    cd ~/Projects/onap/$p
    git fetch
    git reset --hard origin
    git clean -f -d -x
done < projects.txt
