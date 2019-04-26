#!/bin/bash

TC_ONELINE_DESCR="Kill FTPs sever for 10+ sec during download"

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export DR_TC="--tc normal"
export DR_REDIR_TC="--tc normal"
export MR_TC="--tc600"
export BC_TC=""
export NUM_FTPFILES="2"
export NUM_PNFS="700"
export FILE_SIZE="1MB"
export FTP_TYPE="FTPS"

log_sim_settings

start_simulators

mr_equal            ctr_requests                    0 60
dr_equal            ctr_published_files             0 60

mr_print            tc_info
dr_print            tc_info
drr_print           tc_info

start_dfc

dr_greater          ctr_published_files             100 200

kill_ftps
sleep_wait          10       #Server will be gone longer due to long startup time of ftp (ftp file creatation)
start_simulators

dr_equal            ctr_published_files             1400 400

sleep_wait          30

dr_equal            ctr_published_files             1400

mr_greater          ctr_requests                    1

mr_equal            ctr_events                      700
mr_equal            ctr_unique_files                1400
mr_equal            ctr_unique_PNFs                 700

dr_equal            ctr_publish_query               1400
dr_equal            ctr_publish_query_published     0
dr_equal            ctr_publish_query_not_published 1400
dr_equal            ctr_publish_req                 1400
dr_equal            ctr_publish_req_redirect        1400
dr_equal            ctr_publish_req_published       0
dr_equal            ctr_published_files             1400
dr_equal            ctr_double_publish              0

drr_equal           ctr_publish_requests            1400
drr_equal           ctr_publish_responses           1400

drr_equal           dwl_volume                      1400000000

check_dfc_log

#### TEST COMPLETE ####

store_logs          END

print_result