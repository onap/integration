#!/bin/bash

TC_ONELINE_DESCR="100 events with 1 1MB file in each event from one PNF using SFTP with feed reconfigure"

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export MR_TC="--tc110"
export MR_GROUPS="OpenDcae-c12:PM_MEAS_FILES"
export MR_FILE_PREFIX_MAPPING="PM_MEAS_FILES:A"

export DR_TC="--tc normal"
export DR_FEEDS="1:A,2:A"

export DR_REDIR_TC="--tc normal"
export DR_REDIR_FEEDS="1:A,2:A"

export NUM_FTPFILES="200"
export NUM_PNFS="1"
export FILE_SIZE="1MB"
export FTP_TYPE="SFTP"
export FTP_FILE_PREFIXES="A"
export NUM_FTP_SERVERS=1

log_sim_settings

start_simulators

dfc_config_app   0                                    "../simulator-group/dfc_configs/c12_feed2_PM.yaml"

mr_equal            ctr_requests                         0 60
dr_equal            ctr_published_files                  0 60

mr_print            tc_info
dr_print            tc_info
drr_print           tc_info

dr_contain_str      feeds "2:A"
drr_contain_str     feeds "2:A"

start_dfc           0

dr_equal            ctr_published_files                  5 900

dfc_config_app   0                                    "../simulator-group/dfc_configs/c12_feed1_PM.yaml"

mr_equal            ctr_events                           100 1800
mr_equal            ctr_unique_files                     100
mr_equal            ctr_unique_PNFs                      1

dr_greater          ctr_published_files                  1

dr_contain_str      feeds "1:A"
drr_contain_str     feeds "1:A"

check_dfc_logs

#### TEST COMPLETE ####

store_logs          END

print_result
