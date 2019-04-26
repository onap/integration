#!/bin/bash

TC_ONELINE_DESCR="One 5MB file from one PNF in one event using FTPS, from poll to publish"

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export DR_TC="--tc normal"
export DR_REDIR_TC="--tc normal"
export MR_TC="--tc201"
export BC_TC=""
export NUM_FTPFILES="1"
export NUM_PNFS="1"
export FILE_SIZE="5MB"
export FTP_TYPE="FTPS"

log_sim_settings

start_simulators

mr_equal            ctr_requests                    0 60
dr_equal            ctr_published_files             0 60

mr_print            tc_info
dr_print            tc_info
drr_print           tc_info

start_dfc

dr_equal            ctr_published_files             1 60

sleep_wait          30

dr_equal            ctr_published_files             1

mr_greater          ctr_requests                    1

mr_equal            ctr_events                      1
mr_equal            ctr_unique_files                1
mr_equal            ctr_unique_PNFs                 1

dr_equal            ctr_publish_query               1
dr_equal            ctr_publish_query_published     0
dr_equal            ctr_publish_query_not_published 1
dr_equal            ctr_publish_req                 1
dr_equal            ctr_publish_req_redirect        1
dr_equal            ctr_publish_req_published       0
dr_equal            ctr_published_files             1
dr_equal            ctr_double_publish              0

drr_equal           ctr_publish_requests            1
drr_equal           ctr_publish_responses           1

drr_equal           dwl_volume                      5000000

check_dfc_log

#### TEST COMPLETE ####

store_logs          END

print_result