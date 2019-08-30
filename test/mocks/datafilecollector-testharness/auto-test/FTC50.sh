#!/bin/bash

TC_ONELINE_DESCR="Poll 199 new files (100 events) with 10% missing files (20 files with bad file names not existing in FTP server)"

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export MR_TC="--tc121"
export MR_GROUPS="OpenDcae-c12:PM_MEAS_FILES"
export MR_FILE_PREFIX_MAPPING="PM_MEAS_FILES:A"

export DR_TC="--tc normal"
export DR_FEEDS="2:A"

export DR_REDIR_TC="--tc normal"
export DR_REDIR_FEEDS="2:A"

export NUM_FTPFILES="199"
export NUM_PNFS="1"
export FILE_SIZE="1MB"
export FTP_TYPE="SFTP"
export FTP_FILE_PREFIXES="A"
export NUM_FTP_SERVERS=1

log_sim_settings

start_simulators

consul_config_app   0                                    "../simulator-group/consul/c12_feed2_PM.json"

mr_equal            ctr_requests                         0 60
dr_equal            ctr_published_files                  0 60

mr_print            tc_info
dr_print            tc_info
drr_print           tc_info

start_dfc           0

dr_equal            ctr_published_files                  179 5000

sleep_wait          600


dr_equal            ctr_published_files                  179

mr_equal            ctr_events                           100
mr_equal            ctr_unique_files                     179
mr_equal            ctr_unique_PNFs                      1

dr_greater          ctr_publish_query                    179
dr_equal            ctr_publish_query_bad_file_prefix    0
dr_equal            ctr_publish_query_published          0
dr_greater          ctr_publish_query_not_published      179
dr_equal            ctr_publish_req                      179
dr_equal            ctr_publish_req_bad_file_prefix      0
dr_equal            ctr_publish_req_redirect             179
dr_equal            ctr_publish_req_published            0
dr_equal            ctr_published_files                  179

drr_equal           ctr_publish_requests                 179
drr_equal           ctr_publish_requests_bad_file_prefix 0
drr_equal           ctr_publish_responses                179

drr_equal           dwl_volume                           179000000

check_dfc_logs

#### TEST COMPLETE ####

store_logs          END

print_result