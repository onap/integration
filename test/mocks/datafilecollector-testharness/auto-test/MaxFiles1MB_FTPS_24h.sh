#!/bin/bash

TC_ONELINE_DESCR="Maximum number of 1MB FTPS files during 24h, 700 PNFs. 100 new files per event."

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export DR_TC="--tc normal"
export DR_REDIR_TC="--tc normal"
export MR_TC="--tc2200"
export BC_TC=""
export NUM_FTPFILES="3500"
export NUM_PNFS="700"
export FILE_SIZE="1MB"
export FTP_TYPE="FTPS"

log_sim_settings

start_simulators

mr_equal            ctr_requests                    0 60
dr_equal            ctr_published_files             0 60

mr_print            tc_info
dr_print            tc_info
drr_print           tc_info

start_dfc

# 24h MR sim execution time since first poll, should be reached withing 24h +1h margin
mr_contain_str      exe_time_first_poll             1440: $((60*60*24+3600))
# stop event delivery
mr_print            stop
# wait for MR sim values to stabilize
sleep_wait          30

# Requirement number of files, 100 new files in first event for each PNF, then 1 new file per PNF in the
# remaining polls up to 24h. This is the minimum number of published files for the test
TARGET_REQUIRMENT_FILES=$((70000+700*95))

#Calculate targets based on the number of of unique files delivered from MR sim
TARGET_FILES=$(mr_read ctr_unique_files)
TARGET_EVENTS=$((TARGET_FILES/100))
TARGET_VOLUME=$((TARGET_FILES*1000000))

#Maximum number of configured FTP files, if DFC download more than this then the NUM_FTPSFILES need to be increased.
MAX_FILES=$((NUM_FTPFILE*NUM_PNFS))

#Wait remaining time upto 15 min for DFC to download all consumed events
sleep_wait          870

#At least the requiment number of file shall be published
dr_greater          ctr_published_files             $TARGET_REQUIRMENT_FILES

#If greater then MAX_FILES then more FTP files need to be configured
mr_less             ctr_ctr_unique_files            MAX_FILES


#Test that all files from polled events has been downloaded etc

dr_equal            ctr_published_files             $TARGET_FILES

mr_equal            ctr_events                      $TARGET_EVENTS

mr_equal            ctr_unique_PNFs                 700

dr_equal            ctr_publish_query               $TARGET_FILES
dr_equal            ctr_publish_query_published     0
dr_equal            ctr_publish_query_not_published $TARGET_FILES
dr_equal            ctr_publish_req                 $TARGET_FILES
dr_equal            ctr_publish_req_redirect        $TARGET_FILES
dr_equal            ctr_publish_req_published       0
dr_equal            ctr_published_files             $TARGET_FILES

drr_equal           ctr_publish_requests            $TARGET_FILES
drr_equal           ctr_publish_responses           $TARGET_FILES

drr_equal           dwl_volume                      $TARGET_VOLUME

print_all

check_dfc_log

#### TEST COMPLETE ####

store_logs          END

print_result