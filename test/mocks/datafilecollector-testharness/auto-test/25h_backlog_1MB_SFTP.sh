#!/bin/bash

TC_ONELINE_DESCR="Simulating a 25h backlog of events for 700 PNF with decreasing number of missing files, then continues with 15 min events from all PNFs using SFTP"

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export MR_TC="--tc1500"
export MR_GROUPS="OpenDcae-c12:PM_MEAS_FILES"
export MR_FILE_PREFIX_MAPPING="PM_MEAS_FILES:A"

export DR_TC="--tc normal"
export DR_FEEDS="2:A"

export DR_REDIR_TC="--tc normal"
export DR_REDIR_FEEDS="2:A"

export NUM_FTPFILES="300"
export NUM_PNFS="700"
export FILE_SIZE="1MB"
export FTP_TYPE="SFTP"
export FTP_FILE_PREFIXES="A"
export NUM_FTP_SERVERS=5

log_sim_settings

start_simulators


dfc_config_app   0                                    "../simulator-group/dfc_configs/c12_feed2_PM.yaml"

mr_equal            ctr_requests                    0 60
dr_equal            ctr_published_files             0 60

mr_print            tc_info
dr_print            tc_info
drr_print           tc_info

start_dfc 0

mr_equal            ctr_unique_files                70000 18000

mr_print            stop

dr_equal            ctr_published_files             70000 900

sleep_wait          30

dr_equal            ctr_published_files             70000

mr_equal            ctr_events                      70700
mr_equal            ctr_unique_files                70000
mr_equal            ctr_unique_PNFs                 700

check_dfc_logs

#### TEST COMPLETE ####

store_logs          END

print_result
