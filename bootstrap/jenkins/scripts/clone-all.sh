#!/bin/sh
while read p; do
    if [ ! -e $p ]; then
	echo $p
	git clone ssh://gerrit.onap.org:29418/$p $p
    fi
done < projects.txt
