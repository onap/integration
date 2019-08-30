#!/bin/bash

TC_ONELINE_DESCR="DFC start and stop during poll, download and publish."

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export MR_TC="--tc1300"
export MR_GROUPS="OpenDcae-c12:PM_MEAS_FILES"
export MR_FILE_PREFIX_MAPPING="PM_MEAS_FILES:A"

export DR_TC="--tc normal"
export DR_FEEDS="2:A"

export DR_REDIR_TC="--tc normal"
export DR_REDIR_FEEDS="2:A"

export NUM_FTPFILES="200"
export NUM_PNFS="700"
export FILE_SIZE="1MB"
export FTP_TYPE="SFTP"
export FTP_FILE_PREFIXES="A"
export NUM_FTP_SERVERS=5

log_sim_settings

start_simulators

consul_config_app   0                                    "../simulator-group/consul/c12_feed2_PM.json"

mr_equal            ctr_requests                         0 60
dr_equal            ctr_published_files                  0 60

mr_print            tc_info
dr_print            tc_info
drr_print           tc_info

start_dfc           0

mr_equal            ctr_events                           35 120

dfc_contain_str     0                                    heartbeat    "I'm living!"
dfc_contain_str     0                                    stopDatafile "Datafile Service has already been stopped!"

dr_equal            ctr_published_files                  3500 900

sleep_wait          120

dfc_contain_str     0                                    start        "Datafile Service has been started!"

mr_equal            ctr_events                           70 120

dfc_contain_str     0                                    heartbeat    "I'm living!"
dfc_contain_str     0                                    stopDatafile "Datafile Service has already been stopped!"

dr_equal            ctr_published_files                  7000 900

sleep_wait          120

dfc_contain_str     0                                    start        "Datafile Service has been started!"

dr_equal            ctr_published_files                  7000


mr_equal            ctr_events                           70
mr_equal            ctr_unique_files                     7000
mr_equal            ctr_unique_PNFs                      70

dr_equal            ctr_publish_query                    7000
dr_equal            ctr_publish_query_bad_file_prefix    0
dr_equal            ctr_publish_query_published          0
dr_equal            ctr_publish_query_not_published      7000
dr_equal            ctr_publish_req                      7000
dr_equal            ctr_publish_req_bad_file_prefix      0
dr_equal            ctr_publish_req_redirect             7000
dr_equal            ctr_publish_req_published            0
dr_equal            ctr_published_files                  7000

drr_equal           ctr_publish_requests                 7000
drr_equal           ctr_publish_requests_bad_file_prefix 0
drr_equal           ctr_publish_responses                7000

drr_equal           dwl_volume                           7000000000

check_dfc_logs

#### TEST COMPLETE ####

store_logs          END

print_result