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

# build all jobs
cd ~jenkins
for d in jobs/java*; do
    JOB=$(basename "$d")
    echo build "$JOB"
    java -jar jenkins-cli.jar -s http://localhost:8080/ -auth jenkins:jenkins build "$JOB"
done
