#!/bin/bash

TC_ONELINE_DESCR="3500 1MB files from 700 PNFs in 3500 events in 5 polls using SFTP, 3 polls with change ids mapped to feeds and 2 polls not."

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export MR_TC="--tc510"
export MR_GROUPS="OpenDcae-c12:PM_MEAS_FILES:CTR_MEAS_FILES:LOG_FILES:TEMP_FILES"
export MR_FILE_PREFIX_MAPPING="PM_MEAS_FILES:A,CTR_MEAS_FILES:B,LOG_FILES:C,TEMP_FILES:D"

export DR_TC="--tc normal"
export DR_FEEDS="3:A:B"

export DR_REDIR_TC="--tc normal"
export DR_REDIR_FEEDS="3:A:B"

export NUM_FTPFILES="30"
export NUM_PNFS="700"
export FILE_SIZE="1MB"
export FTP_TYPE="SFTP"
export FTP_FILE_PREFIXES="A,B,C,D"
export NUM_FTP_SERVERS=1

log_sim_settings

start_simulators

dfc_config_app   0                                    "../simulator-group/dfc_configs/c12_feed3_PM_CTR.yaml"

mr_equal            ctr_requests                         0 60
dr_equal            ctr_published_files                  0 60

mr_print            tc_info
dr_print            tc_info
drr_print           tc_info

start_dfc           0

dr_equal            ctr_published_files                  2100 900
dr_equal            ctr_published_files/3                2100
sleep_wait          30

dr_equal            ctr_published_files                  2100
dr_equal            ctr_published_files/3                2100

mr_greater          ctr_requests                         5

mr_equal            ctr_events                           3500
mr_equal            ctr_unique_files                     3500
mr_equal            ctr_unique_PNFs                      700

dr_equal            ctr_publish_query                    2100
dr_equal            ctr_publish_query/3                  2100
dr_equal            ctr_publish_query_bad_file_prefix    0
dr_equal            ctr_publish_query_published          0
dr_equal            ctr_publish_query_not_published      2100
dr_equal            ctr_publish_query_not_published/3    2100
dr_equal            ctr_publish_req                      2100
dr_equal            ctr_publish_req/3                    2100
dr_equal            ctr_publish_req_bad_file_prefix      0
dr_equal            ctr_publish_req_redirect             2100
dr_equal            ctr_publish_req_redirect/3           2100
dr_equal            ctr_publish_req_published            0
dr_equal            ctr_published_files                  2100
dr_equal            ctr_published_files/3                2100
dr_equal            ctr_double_publish                   0

drr_equal           ctr_publish_requests                 2100
drr_equal           ctr_publish_requests/3               2100
drr_equal           ctr_publish_requests_bad_file_prefix 0
drr_equal           ctr_publish_responses                2100
drr_equal           ctr_publish_responses/3              2100

drr_equal           dwl_volume                           2100000000
drr_equal           dwl_volume/3                         2100000000

check_dfc_logs

#### TEST COMPLETE ####

store_logs          END

print_result
