#!/bin/bash

TC_ONELINE_DESCR="100 events (1 evt per poll) per DFC with 100 1MB files from one PNF using two DFC (different consumer groups) each publishing using unique change ids/feeds over SFTP."

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export MR_TC="--tc111"
export MR_GROUPS="OpenDcae-c12:PM_MEAS_FILES:CTR_MEAS_FILES,OpenDcae-c13:PM_MEAS_FILES:CTR_MEAS_FILES"
export MR_FILE_PREFIX_MAPPING="PM_MEAS_FILES:A,CTR_MEAS_FILES:B"

export DR_TC="--tc normal"
export DR_FEEDS="1:A,2:B"

export DR_REDIR_TC="--tc normal"
export DR_REDIR_FEEDS="1:A,2:B"

export NUM_FTPFILES="1000"
export NUM_PNFS="1"
export FILE_SIZE="1MB"
export FTP_TYPE="SFTP"
export FTP_FILE_PREFIXES="A,B"
export NUM_FTP_SERVERS=1

log_sim_settings

start_simulators

dfc_config_app   0                                    "../simulator-group/dfc_configs/c12_feed1_PM.yaml"
dfc_config_app   1                                    "../simulator-group/dfc_configs/c13_feed2_CTR.yaml"

mr_equal            ctr_requests                         0 60
dr_equal            ctr_published_files                  0 60

mr_print            tc_info
dr_print            tc_info
drr_print           tc_info

start_dfc           0
start_dfc           1

dr_equal            ctr_published_files                  396 2000

sleep_wait          30

dr_equal            ctr_published_files                  396

mr_greater          ctr_requests                         200

mr_equal            ctr_events                           200
mr_equal            ctr_unique_files                     792
mr_equal            ctr_unique_PNFs                      2
mr_equal            ctr_unique_PNFs/OpenDcae-c12         1
mr_equal            ctr_unique_PNFs/OpenDcae-c13         1

dr_equal            ctr_publish_query                    396
dr_equal            ctr_publish_query/1                  198
dr_equal            ctr_publish_query/2                  198
dr_equal            ctr_publish_query_bad_file_prefix    0
dr_equal            ctr_publish_query_published          0
dr_equal            ctr_publish_query_not_published      396
dr_equal            ctr_publish_query_not_published/1    198
dr_equal            ctr_publish_query_not_published/2    198
dr_equal            ctr_publish_req                      396
dr_equal            ctr_publish_req/1                    198
dr_equal            ctr_publish_req/2                    198
dr_equal            ctr_publish_req_bad_file_prefix      0
dr_equal            ctr_publish_req_redirect             396
dr_equal            ctr_publish_req_redirect/1           198
dr_equal            ctr_publish_req_redirect/2           198
dr_equal            ctr_publish_req_published            0
dr_equal            ctr_published_files                  396
dr_equal            ctr_published_files/1                198
dr_equal            ctr_published_files/2                198
dr_equal            ctr_double_publish                   0

drr_equal           ctr_publish_requests                 396
drr_equal           ctr_publish_requests/1               198
drr_equal           ctr_publish_requests/2               198
drr_equal           ctr_publish_requests_bad_file_prefix 0
drr_equal           ctr_publish_responses                396
drr_equal           ctr_publish_responses/1              198
drr_equal           ctr_publish_responses/2              198

drr_equal           dwl_volume                           396000000
drr_equal           dwl_volume/1                         198000000
drr_equal           dwl_volume/2                         198000000

check_dfc_logs

#### TEST COMPLETE ####

store_logs          END

print_result
