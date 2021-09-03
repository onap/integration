#!/bin/bash

TC_ONELINE_DESCR="25 events for each 4 feeds with 100 1MB files per event from one PNF using SFTP, 1 change id with no feed, 1 change with one feed and two change id to one feed."

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export MR_TC="--tc111"
export MR_GROUPS="OpenDcae-c12:PM_MEAS_FILES:CTR_MEAS_FILES:LOG_FILES:TEMP_FILES"
export MR_FILE_PREFIX_MAPPING="PM_MEAS_FILES:A,CTR_MEAS_FILES:B,LOG_FILES:C,TEMP_FILES:D"

export DR_TC="--tc normal"
export DR_FEEDS="2:B,3:C:D"

export DR_REDIR_TC="--tc normal"
export DR_REDIR_FEEDS="2:B,3:C:D"

export NUM_FTPFILES="200"
export NUM_PNFS="1"
export FILE_SIZE="1MB"
export FTP_TYPE="SFTP"
export FTP_FILE_PREFIXES="A,B,C,D"
export NUM_FTP_SERVERS=1

log_sim_settings

start_simulators

dfc_config_app   0                                    "../simulator-group/dfc_configs/c12_feed2_CTR_feed3_LOG_TEMP.yaml"

mr_equal            ctr_requests                         0 60
dr_equal            ctr_published_files                  0 60

mr_print            tc_info
dr_print            tc_info
drr_print           tc_info

start_dfc           0

dr_equal            ctr_published_files                  588 2000
dr_equal            ctr_published_files/2                196
dr_equal            ctr_published_files/3                392
sleep_wait          30

dr_equal            ctr_published_files                  588
dr_equal            ctr_published_files/2                196
dr_equal            ctr_published_files/3                392

mr_greater          ctr_requests                         100

mr_equal            ctr_events                           100
mr_equal            ctr_unique_files                     784
mr_equal            ctr_unique_PNFs                      1

dr_equal            ctr_publish_query                    588
dr_equal            ctr_publish_query/2                  196
dr_equal            ctr_publish_query/3                  392
dr_equal            ctr_publish_query_bad_file_prefix    0
dr_equal            ctr_publish_query_published          0
dr_equal            ctr_publish_query_not_published      588
dr_equal            ctr_publish_query_not_published/2    196
dr_equal            ctr_publish_query_not_published/3    392
dr_equal            ctr_publish_req                      588
dr_equal            ctr_publish_req/2                    196
dr_equal            ctr_publish_req/3                    392
dr_equal            ctr_publish_req_bad_file_prefix      0
dr_equal            ctr_publish_req_redirect             588
dr_equal            ctr_publish_req_redirect/2           196
dr_equal            ctr_publish_req_redirect/3           392
dr_equal            ctr_publish_req_published            0
dr_equal            ctr_published_files                  588
dr_equal            ctr_published_files/2                196
dr_equal            ctr_published_files/3                392
dr_equal            ctr_double_publish                   0

drr_equal           ctr_publish_requests                 588
drr_equal           ctr_publish_requests/2               196
drr_equal           ctr_publish_requests/3               392
drr_equal           ctr_publish_requests_bad_file_prefix 0
drr_equal           ctr_publish_responses                588
drr_equal           ctr_publish_responses/2              196
drr_equal           ctr_publish_responses/3              392

drr_equal           dwl_volume                           588000000
drr_equal           dwl_volume/2                         196000000
drr_equal           dwl_volume/3                         392000000

check_dfc_logs

#### TEST COMPLETE ####

print_all

store_logs          END

print_result
