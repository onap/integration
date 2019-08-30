#!/bin/bash

TC_ONELINE_DESCR="Stabilty over 72hours, 700 PNFs over SFTP. All new files (100) in first event from PNF, then one new 1 new file per event."

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

export NUM_FTPFILES="1000"
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

# 72h MR sim execution time since first poll, should be reached withing 72h + 1h margin
mr_contain_str      exe_time_first_poll                  4320: $((60*60*24*3+3600))

# Requirement number of files, 100 new files in first event for each PNF, then 1 new file per PNF in the
# remaining 15 min polls up to 72h. This is the minimum number of published files for the test
TARGET_REQUIRMENT_FILES=$((70000+700*95+700*96+700*96))

#Make sure target is reached within 72h + a reasonable tolerance
mr_greater         ctr_unique_files                      $((TARGET_REQUIRMENT_FILES-1)) 1800

# stop event delivery
mr_print            stop
# wait for MR sim values to stabilize
sleep_wait          30

#Calculate targets based on the number of of unique files delivered from MR sim
TARGET_FILES=$(mr_read ctr_unique_files)
TARGET_EVENTS=$((TARGET_FILES-70000+700))    #First event from a PNF is 100 new files, remaining events contains 1 new file
TARGET_VOLUME=$((TARGET_FILES*1000000))

#Maximum number of configured FTP files, if DFC reach this then the NUM_FTPSFILES need to be increased.
MAX_FILES=$((NUM_FTPFILES*NUM_PNFS))

#Wait remaining time upto 15 min for DFC to download all consumed events
sleep_wait          870

#At least the requiment number of file shall be published
dr_greater          ctr_published_files                  $((TARGET_REQUIRMENT_FILES-1))

#If greater then MAX_FILES then more FTP files need to be configured
mr_less             ctr_unique_files                     $MAX_FILES


#Test that all files from polled events has been downloaded etc

dr_equal            ctr_published_files                  $TARGET_FILES

mr_equal            ctr_events                           $TARGET_EVENTS

mr_equal            ctr_unique_PNFs                      700

dr_equal            ctr_publish_query                    $TARGET_FILES
dr_equal            ctr_publish_query_bad_file_prefix    0
dr_equal            ctr_publish_query_published          0
dr_equal            ctr_publish_query_not_published      $TARGET_FILES
dr_equal            ctr_publish_req                      $TARGET_FILES
dr_equal            ctr_publish_req_bad_file_prefix      0
dr_equal            ctr_publish_req_redirect             $TARGET_FILES
dr_equal            ctr_publish_req_published            0
dr_equal            ctr_published_files                  $TARGET_FILES
dr_equal            ctr_double_publish                   0

drr_equal           ctr_publish_requests                 $TARGET_FILES
drr_equal           ctr_publish_requests_bad_file_prefix 0
drr_equal           ctr_publish_responses                $TARGET_FILES

drr_equal           dwl_volume                           $TARGET_VOLUME

print_all

check_dfc_logs

#### TEST COMPLETE ####

store_logs          END

print_result