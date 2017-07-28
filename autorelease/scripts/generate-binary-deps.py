#!/usr/bin/env python
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import sys, csv, subprocess

version = "1.1.0-SNAPSHOT"

root = subprocess.check_output(["git", "rev-parse", "--show-toplevel"]).rstrip()

with open( "{}/autorelease/binaries.csv".format(root), "r" ) as f:
    reader = csv.DictReader(f)
    errors = 0

    items = []
    for row in reader:
        txt = """
    <dependency>
      <groupId>{}</groupId>
      <artifactId>{}</artifactId>
      <version>{}</version>
      <type>{}</type>
      <classifier>{}</classifier>
    </dependency>"""
        print txt.format(row["groupId"], row["artifactId"], version, row["extension"], row["classifier"])
        
