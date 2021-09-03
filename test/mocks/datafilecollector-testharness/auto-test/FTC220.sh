#!/bin/bash

TC_ONELINE_DESCR="DFC stop before polling event (no polling during stopped), then dfc start."

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export MR_TC="--tc100"
export MR_GROUPS="OpenDcae-c12:PM_MEAS_FILES"
export MR_FILE_PREFIX_MAPPING="PM_MEAS_FILES:A"

export DR_TC="--tc normal"
export DR_FEEDS="2:A"

export DR_REDIR_TC="--tc normal"
export DR_REDIR_FEEDS="2:A"

export NUM_FTPFILES="1"
export NUM_PNFS="1"
export FILE_SIZE="1MB"
export FTP_TYPE="SFTP"
export FTP_FILE_PREFIXES="A"
export NUM_FTP_SERVERS=1

log_sim_settings

start_simulators

dfc_config_app   0                                    "../simulator-group/dfc_configs/c12_feed2_PM.yaml"

mr_equal            ctr_requests                         0 30

kill_mr

start_dfc           0

sleep_wait          30

dfc_contain_str     0                                    stopDatafile "Datafile Service has already been stopped!"

start_simulators

sleep_wait          120

mr_equal            ctr_requests                         0

dfc_contain_str     0                                    start        "Datafile Service has been started!"

dr_equal            ctr_published_files                  1 60

mr_greater          ctr_requests                         0

mr_equal            ctr_events                           1
mr_equal            ctr_unique_files                     1
mr_equal            ctr_unique_PNFs                      1

dr_equal            ctr_publish_query                    1
dr_equal            ctr_publish_query_bad_file_prefix    0
dr_equal            ctr_publish_query_published          0
dr_equal            ctr_publish_query_not_published      1
dr_equal            ctr_publish_req                      1
dr_equal            ctr_publish_req_bad_file_prefix      0
dr_equal            ctr_publish_req_redirect             1
dr_equal            ctr_publish_req_published            0
dr_equal            ctr_published_files                  1
dr_equal            ctr_double_publish                   0

drr_equal           ctr_publish_requests                 1
drr_equal           ctr_publish_requests_bad_file_prefix 0
drr_equal           ctr_publish_responses                1

drr_equal           dwl_volume                           1000000

check_dfc_logs

#### TEST COMPLETE ####

store_logs          END

print_result
