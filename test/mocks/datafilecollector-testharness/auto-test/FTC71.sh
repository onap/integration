#!/bin/bash

TC_ONELINE_DESCR="199 file publish attempt where all calls to DR sim and DR redir sim responds after 10s delay"

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export DR_TC="--tc all_delay_10s"
export DR_REDIR_TC="--tc all_delay_10s"
export MR_TC="--tc113"
export BC_TC=""
export NUM_FTPFILES="199"
export NUM_PNFS="1"
export FILE_SIZE="1MB"
export FTP_TYPE="SFTP"

log_sim_settings

start_simulators

mr_equal            ctr_requests                    0 60
dr_equal            ctr_published_files             0 60

mr_print            tc_info
dr_print            tc_info
drr_print           tc_info

start_dfc

dr_equal            ctr_published_files             199 300

sleep_wait          30

dr_equal            ctr_published_files             199

mr_greater          ctr_requests                    1

mr_equal            ctr_events                      100
mr_equal            ctr_unique_files                199
mr_equal            ctr_unique_PNFs                 1

dr_equal            ctr_publish_query               199
dr_equal            ctr_publish_query_published     0
dr_equal            ctr_publish_query_not_published 199
dr_equal            ctr_publish_req                 199
dr_equal            ctr_publish_req_redirect        199
dr_equal            ctr_publish_req_published       0
dr_equal            ctr_published_files             199
dr_equal            ctr_double_publish              0

drr_equal         ctr_publish_requests            199
drr_equal           ctr_publish_responses           199

drr_equal           dwl_volume                      199000000

check_dfc_log

#### TEST COMPLETE ####

store_logs          END

print_result