#!/bin/bash

TC_ONELINE_DESCR="DFC file retention (files with SFTP and then same files overSFTP). 1MB, 5MB and 50MB using first SFTP and thenSFTP with restart of MR between each file."

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export DR_TC="--tc normal"
export DR_REDIR_TC="--tc normal"
export MR_TC="--tc100"
export BC_TC=""
export NUM_FTPFILES="1"
export NUM_PNFS="1"
export FILE_SIZE="ALL"
export FTP_TYPE="ALL"

log_sim_settings

start_simulators

mr_equal            ctr_requests                    0 60
dr_equal            ctr_published_files             0 60


start_dfc

mr_equal            ctr_events                      1 60
mr_contain_str      tc_info                         "TC#100"
dr_equal            ctr_published_files             1 30


kill_mr
export MR_TC="--tc101"
log_sim_settings
start_simulators

mr_print            tc_info
mr_equal            ctr_events                      1 60
mr_contain_str      tc_info                         "TC#101"
dr_equal            ctr_published_files             2 30

kill_mr
export MR_TC="--tc102"
log_sim_settings
start_simulators

mr_print            tc_info
mr_equal            ctr_events                      1 60
mr_contain_str      tc_info                         "TC#102"
dr_equal            ctr_published_files             3 30

kill_mr
export MR_TC="--tc200"
log_sim_settings
start_simulators

mr_print            tc_info
mr_equal            ctr_events                      1 60
mr_contain_str      tc_info                         "TC#200"
dr_equal            ctr_published_files             3 30

kill_mr
export MR_TC="--tc201"
start_simulators


mr_print            tc_info
mr_equal            ctr_events                      1 60
mr_contain_str      tc_info                         "TC#201"
dr_equal            ctr_published_files             3 30

kill_mr
export MR_TC="--tc202"
start_simulators


mr_print            tc_info
mr_equal            ctr_events                      1 60
mr_contain_str      tc_info                         "TC#202"
dr_equal            ctr_published_files             3 30


dr_equal            ctr_publish_query               3
dr_equal            ctr_publish_query_published     0
dr_equal            ctr_publish_query_not_published 3
dr_equal            ctr_publish_req                 3
dr_equal            ctr_publish_req_redirect        3
dr_equal            ctr_publish_req_published       0
dr_equal            ctr_published_files             3
dr_equal            ctr_double_publish              0

drr_equal           ctr_publish_requests            3
drr_equal           ctr_publish_responses           3

drr_equal           dwl_volume                      56000000

check_dfc_log

#### TEST COMPLETE ####

store_logs END

print_result