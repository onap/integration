#!/bin/bash

TC_ONELINE_DESCR="DFC start and stop during poll, download and publish."

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export DR_TC="--tc normal"
export DR_REDIR_TC="--tc normal"
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

mr_greater          ctr_events                      0 120
dr_print            ctr_published_files


dfc_contain_str     heartbeat                       "I'm living!"
dfc_contain_str     stopDatafile                    "Datafile Service has already been stopped!"

sleep_wait          120

dfc_contain_str     start                           "Datafile Service has been started!"

dr_greater          ctr_published_files             100 60
dr_less             ctr_published_files             199
dr_print            ctr_published_files

dfc_contain_str     heartbeat                       "I'm living!"
dfc_contain_str     stopDatafile                    "Datafile Service has already been stopped!"

sleep_wait          120

dfc_contain_str     start                           "Datafile Service has been started!"

dr_equal            ctr_published_files             199 60


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

drr_equal           ctr_publish_requests            199
drr_equal           ctr_publish_responses           199

drr_equal           dwl_volume                      199000000

check_dfc_log

#### TEST COMPLETE ####

store_logs          END

print_result