#!/bin/bash
#
# Copyright (C) 2021 Nokia. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

TC_ONELINE_DESCR="One 1MB file from one PNF in one event using HTTPS, from poll to publish"

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export MR_TC="--tc400"
export MR_GROUPS="OpenDcae-c12:PM_MEAS_FILES"
export MR_FILE_PREFIX_MAPPING="PM_MEAS_FILES:A"

export DR_TC="--tc normal"
export DR_FEEDS="2:A"

export DR_REDIR_TC="--tc normal"
export DR_REDIR_FEEDS="2:A"

export NUM_HTTPFILES="10"
export NUM_PNFS="1"
export FILE_SIZE="1MB"
export HTTP_TYPE="HTTPS"
export HTTP_FILE_PREFIXES="A"
export NUM_HTTP_SERVERS=1

log_sim_settings

start_simulators

dfc_config_app   0                                    "../simulator-group/dfc_configs/c12_feed2_PM_HTTPS.yaml"

mr_equal            ctr_requests                         0 60
dr_equal            ctr_published_files                  0 60

mr_print            tc_info
dr_print            tc_info
drr_print           tc_info

start_dfc           0

dr_equal            ctr_published_files                  1 60

sleep_wait          30

dr_equal            ctr_published_files                  1

mr_greater          ctr_requests                         1

mr_equal            ctr_events                           1
mr_equal            ctr_unique_files                     1
mr_equal            ctr_unique_PNFs                      1

dr_equal            ctr_publish_query                    1
dr_equal            ctr_publish_query_bad_file_prefix    0
dr_equal            ctr_publish_query_published          0
dr_equal            ctr_publish_query_not_published      1
dr_equal            ctr_publish_req                      1
dr_equal            ctr_publish_req_bad_file_prefix      0
dr_equal            ctr_publish_req_redirect             1
dr_equal            ctr_publish_req_published            0
dr_equal            ctr_published_files                  1
dr_equal            ctr_double_publish                   0

drr_equal           ctr_publish_requests                 1
drr_equal           ctr_publish_requests_bad_file_prefix 0
drr_equal           ctr_publish_responses                1

drr_equal           dwl_volume                           1000000

check_dfc_logs

#### TEST COMPLETE ####

store_logs          END

print_result
