#!/bin/bash

TS_ONELINE_DESCR="Single file tests suite"

. ../common/testsuite_common.sh

suite_setup

############# TEST CASES #################

./FTC1.sh $1 $2
./FTC2.sh $1 $2
./FTC3.sh $1 $2
./FTC4.sh $1 $2
./FTC5.sh $1 $2
./FTC6.sh $1 $2

##########################################

suite_complete

