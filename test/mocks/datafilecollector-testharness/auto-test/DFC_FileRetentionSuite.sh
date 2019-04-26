#!/bin/bash

TS_ONELINE_DESCR="DFC file retention (avoid double publish)"

. ../common/testsuite_common.sh

suite_setup

############# TEST CASES #################

run_tc FTC30.sh $1 $2
run_tc FTC31.sh $1 $2
run_tc FTC32.sh $1 $2
run_tc FTC33.sh $1 $2

##########################################

suite_complete

