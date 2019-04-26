#!/bin/bash

TC_ONELINE_DESCR="72800 1MB files from 700 PNFs in 3500 events in 100 polls (35 PNFs each 100 files per poll) using FTPS, from poll to publish."

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export DR_TC="--tc normal"
export DR_REDIR_TC="--tc normal"
export MR_TC="--tc810"
export BC_TC=""
export NUM_FTPFILES="105"
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

dr_equal            ctr_published_files             72800 18000

sleep_wait          30

dr_equal            ctr_published_files             72800

mr_greater          ctr_requests                    100

mr_equal            ctr_events                      3500
mr_equal            ctr_unique_files                72800
mr_equal            ctr_unique_PNFs                 700

dr_equal            ctr_publish_query               72800
dr_equal            ctr_publish_query_published     0
dr_equal            ctr_publish_query_not_published 72800
dr_equal            ctr_publish_req                 72800
dr_equal            ctr_publish_req_redirect        72800
dr_equal            ctr_publish_req_published       0
dr_equal            ctr_published_files             72800
dr_equal            ctr_double_publish              0

drr_equal           ctr_publish_requests            72800
drr_equal           ctr_publish_responses           72800

drr_equal           dwl_volume                      72800000000

check_dfc_log

#### TEST COMPLETE ####

store_logs          END

print_result