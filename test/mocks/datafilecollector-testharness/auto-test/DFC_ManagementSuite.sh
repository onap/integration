#!/bin/bash

TS_ONELINE_DESCR="DFC rest API management"

. ../common/testsuite_common.sh

suite_setup

############# TEST CASES #################

run_tc FTC200.sh $1 $2
run_tc FTC210.sh $1 $2
run_tc FTC220.sh $1 $2

##########################################

suite_complete

