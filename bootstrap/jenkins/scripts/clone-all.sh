#!/bin/sh
while read p; do
    echo $p
    git clone ssh://gerrit.onap.org:29418/$p $p
done < projects.txt
