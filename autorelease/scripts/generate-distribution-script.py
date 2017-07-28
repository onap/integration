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

root = subprocess.check_output(["git", "rev-parse", "--show-toplevel"]).rstrip()
url_template = "https://nexus.open-o.org/service/local/artifact/maven/redirect?r=releases&g={0}&a={1}&e={2}&c={3}&v=$VERSION"

def parseRow(row):
    service = row["service"]
    filename = row["filename"]
    groupId = row["groupId"]
    artifactId = row["artifactId"]
    extension = row["extension"]
    classifier = row["classifier"]
    url = url_template.format(groupId, artifactId, extension, classifier)
    if classifier:
        dest = "{}/{}-$VERSION.{}.{}".format(filename, filename, classifier, extension)
    else:
        dest = "{}/{}-$VERSION.{}".format(filename, filename, extension)
    return {"url": url, "dest": dest}


with open( "{}/autorelease/binaries.csv".format(root), "r" ) as f:
    reader = csv.DictReader(f)
    errors = 0

    print """
#!/bin/bash
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
#

VERSION=2.0.0

set +e

"""
    items = []
    for row in reader:
        item = parseRow(row)
        items.append(item)

        print "# {}".format(row["service"])
        print "mkdir -p {}".format(row["filename"])
        print "wget -O \"{}\" \"{}\"".format(item["dest"], item["url"])
        print ""
