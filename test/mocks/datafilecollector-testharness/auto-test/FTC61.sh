#!/bin/bash

TC_ONELINE_DESCR="Kill FTPES sever for 10+ sec during download"

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export MR_TC="--tc600"
export MR_GROUPS="OpenDcae-c12:PM_MEAS_FILES"
export MR_FILE_PREFIX_MAPPING="PM_MEAS_FILES:A"

export DR_TC="--tc normal"
export DR_FEEDS="2:A"

export DR_REDIR_TC="--tc normal"
export DR_REDIR_FEEDS="2:A"

export NUM_FTPFILES="2"
export NUM_PNFS="700"
export FILE_SIZE="1MB"
export FTP_TYPE="FTPES"
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

dr_greater          ctr_published_files                  100 200

stop_ftpes           0
sleep_wait          30
start_ftpes          0

dr_equal            ctr_published_files                  1400 400

sleep_wait          30

dr_equal            ctr_published_files                  1400

mr_greater          ctr_requests                         1

mr_equal            ctr_events                           700
mr_equal            ctr_unique_files                     1400
mr_equal            ctr_unique_PNFs                      700

dr_equal            ctr_publish_query                    1400
dr_equal            ctr_publish_query_bad_file_prefix    0
dr_equal            ctr_publish_query_published          0
dr_equal            ctr_publish_query_not_published      1400
dr_equal            ctr_publish_req                      1400
dr_equal            ctr_publish_req_bad_file_prefix      0
dr_equal            ctr_publish_req_redirect             1400
dr_equal            ctr_publish_req_published            0
dr_equal            ctr_published_files                  1400
dr_equal            ctr_double_publish                   0

drr_equal           ctr_publish_requests                 1400
drr_equal           ctr_publish_requests_bad_file_prefix 0
drr_equal           ctr_publish_responses                1400

drr_equal           dwl_volume                           1400000000

check_dfc_logs

#### TEST COMPLETE ####

store_logs          END

print_result
