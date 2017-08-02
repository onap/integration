#!/bin/sh
#
# Copyright 2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
find $1 -mindepth 0 -type d -exec test -e "{}/pom.xml" ';' -prune -printf "%P\n" | sort
