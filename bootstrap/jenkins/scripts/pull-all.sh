#!/bin/bash
while read p; do
    if [ ! -e $p ]; then
	echo $p
	git clone ssh://gerrit.onap.org:29418/$p $p
    else
	pushd $p > /dev/null
	# git fetch
	# git reset --hard origin
	echo -ne "$p:\t"
	git pull
	popd > /dev/null
    fi
done < projects.txt
