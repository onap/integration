#!/bin/bash

TS_ONELINE_DESCR="All test cases suite (excluding 24 h max test and 72 stab test)"

. ../common/testsuite_common.sh

suite_setup

############# TEST CASES #################

run_tc FTC1.sh $1 $2
run_tc FTC2.sh $1 $2
run_tc FTC3.sh $1 $2
run_tc FTC4.sh $1 $2
run_tc FTC5.sh $1 $2
run_tc FTC6.sh $1 $2

run_tc FTC10.sh $1 $2
run_tc FTC11.sh $1 $2
run_tc FTC12.sh $1 $2
run_tc FTC13.sh $1 $2
run_tc FTC14.sh $1 $2
run_tc FTC15.sh $1 $2

run_tc FTC20.sh $1 $2
run_tc FTC21.sh $1 $2

run_tc FTC30.sh $1 $2
run_tc FTC31.sh $1 $2
run_tc FTC32.sh $1 $2
run_tc FTC33.sh $1 $2

run_tc FTC40.sh $1 $2

run_tc FTC50.sh $1 $2

run_tc FTC60.sh $1 $2
run_tc FTC61.sh $1 $2

run_tc FTC70.sh $1 $2
run_tc FTC71.sh $1 $2

run_tc FTC80.sh $1 $2
run_tc FTC81.sh $1 $2

run_tc FTC90.sh $1 $2

run_tc FTC100.sh $1 $2

run_tc FTC200.sh $1 $2
run_tc FTC210.sh $1 $2
run_tc FTC220.sh $1 $2




##########################################

suite_complete
