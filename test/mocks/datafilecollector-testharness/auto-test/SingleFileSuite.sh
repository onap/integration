#!/bin/bash
#
# Modifications copyright (C) 2021 Nokia. All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

TS_ONELINE_DESCR="Single file tests suite"

. ../common/testsuite_common.sh

suite_setup

############# TEST CASES #################

./FTC1.sh "$1" "$2"
./FTC2.sh "$1" "$2"
./FTC3.sh "$1" "$2"
./FTC4.sh "$1" "$2"
./FTC5.sh "$1" "$2"
./FTC6.sh "$1" "$2"
./FTC7.sh "$1" "$2"
./FTC8.sh "$1" "$2"
./FTC9.sh "$1" "$2"
./FTC400.sh "$1" "$2"
./FTC401.sh "$1" "$2"
./FTC402.sh "$1" "$2"
./FTC403.sh "$1" "$2"
./FTC404.sh "$1" "$2"

##########################################

suite_complete

