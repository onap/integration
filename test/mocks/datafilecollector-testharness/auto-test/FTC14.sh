#!/bin/bash

TC_ONELINE_DESCR="3500 50MB files from 700 PNFs in 3500 events in 5 polls using SFTP, from poll to publish."

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export MR_TC="--tc550"
export MR_GROUPS="OpenDcae-c12:PM_MEAS_FILES"
export MR_FILE_PREFIX_MAPPING="PM_MEAS_FILES:A"

export DR_TC="--tc normal"
export DR_FEEDS="2:A"

export DR_REDIR_TC="--tc normal"
export DR_REDIR_FEEDS="2:A"

export NUM_FTPFILES="5"
export NUM_PNFS="700"
export FILE_SIZE="50MB"
export FTP_TYPE="SFTP"
export FTP_FILE_PREFIXES="A"
export NUM_FTP_SERVERS=5

log_sim_settings

start_simulators

dfc_config_app   0                                    "../simulator-group/dfc_configs/c12_feed2_PM.yaml"

mr_equal            ctr_requests                         0 60
dr_equal            ctr_published_files                  0 60

mr_print            tc_info
dr_print            tc_info
drr_print           tc_info

start_dfc           0

dr_equal            ctr_published_files                  3500 3600

sleep_wait          30

dr_equal            ctr_published_files                  3500

mr_greater          ctr_requests                         5

mr_equal            ctr_events                           3500
mr_equal            ctr_unique_files                     3500
mr_equal            ctr_unique_PNFs                      700

dr_equal            ctr_publish_query                    3500
dr_equal            ctr_publish_query_bad_file_prefix    0
dr_equal            ctr_publish_query_published          0
dr_equal            ctr_publish_query_not_published      3500
dr_equal            ctr_publish_req                      3500
dr_equal            ctr_publish_req_bad_file_prefix      0
dr_equal            ctr_publish_req_redirect             3500
dr_equal            ctr_publish_req_published            0
dr_equal            ctr_published_files                  3500
dr_equal            ctr_double_publish                   0

drr_equal           ctr_publish_requests                 3500
drr_equal           ctr_publish_requests_bad_file_prefix 0
drr_equal           ctr_publish_responses                3500

drr_equal           dwl_volume                           175000000000

check_dfc_logs

#### TEST COMPLETE ####

store_logs          END

print_result
