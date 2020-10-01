#!/bin/bash
#
# Copyright 2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
while read p; do
    if [ ! -e $p ]; then
	echo $p
	git clone --depth 1 ssh://gerrit.onap.org:29418/$p $p
    else
	pushd $p > /dev/null
	# git fetch
	# git reset --hard origin
	echo -ne "$p:\t"
	git pull
	popd > /dev/null
    fi
done < projects.txt
