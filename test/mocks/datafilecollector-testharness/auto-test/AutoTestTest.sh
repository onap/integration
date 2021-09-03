#!/bin/bash

TC_ONELINE_DESCR="Test script for auto test and simulator control"

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####

clean_containers

export MR_TC="--tc1000"
export MR_GROUPS="OpenDcae-c12:PM_MEAS_FILES:CTR_MEAS_FILES,OpenDcae-c13:CTR_MEAS_FILES,OpenDcae-c14:LOG_FILES,OpenDcae-c15:PM_MEAS_FILES:TEST_FILES,OpenDcae-c16:TEST_FILES:TEMP_FILES"
export MR_FILE_PREFIX_MAPPING="PM_MEAS_FILES:A,CTR_MEAS_FILES:B,LOG_FILES:C,TEST_FILES:D,TEMP_FILES:E"

export DR_TC="--tc normal"
export DR_FEEDS="1:A,2:B,3:C,4:D,5:E"

export DR_REDIR_TC="--tc normal"
export DR_REDIR_FEEDS="1:A,2:B,3:C,4:D,5:E"

export NUM_FTPFILES="300"
export NUM_PNFS="5"
export FILE_SIZE="1MB"
export FTP_TYPE="SFTP"
export FTP_FILE_PREFIXES="A,B,C,D,E"
export NUM_FTP_SERVERS=5



log_sim_settings

start_simulators

dfc_config_app   0 "../simulator-group/dfc_configs/c12_feed1_PM_feed2_CTR.yaml"

dfc_config_app   1 "../simulator-group/dfc_configs/c13_feed2_CTR.yaml"

dfc_config_app   2 "../simulator-group/dfc_configs/c14_feed3_LOG.yaml"

dfc_config_app   3 "../simulator-group/dfc_configs/c15_feed1_PM_feed4_TEST.yaml"

dfc_config_app   2 "../simulator-group/dfc_configs/c16_feed4_TEST_feed5_TEMP.yaml"


mr_print			""
mr_print			groups
mr_print			changeids
mr_print			fileprefixes
mr_print			tc_info
mr_print			status
mr_print			stop
mr_print			start

mr_print			ctr_requests
mr_print			groups/ctr_requests
mr_print			ctr_requests/OpenDcae-c12
mr_print			ctr_requests/OpenDcae-c13
mr_print			ctr_requests/OpenDcae-c14
mr_print			ctr_requests/OpenDcae-c15
mr_print			ctr_requests/OpenDcae-c16

mr_print			ctr_responses
mr_print			groups/ctr_responses
mr_print			ctr_responses/OpenDcae-c12
mr_print			ctr_responses/OpenDcae-c13
mr_print			ctr_responses/OpenDcae-c14
mr_print			ctr_responses/OpenDcae-c15
mr_print			ctr_responses/OpenDcae-c16

mr_print			ctr_files
mr_print			groups/ctr_files
mr_print			ctr_files/OpenDcae-c12
mr_print			ctr_files/OpenDcae-c13
mr_print			ctr_files/OpenDcae-c14
mr_print			ctr_files/OpenDcae-c15
mr_print			ctr_files/OpenDcae-c16

mr_print			ctr_unique_files
mr_print			groups/ctr_unique_files
mr_print			ctr_unique_files/OpenDcae-c12
mr_print			ctr_unique_files/OpenDcae-c13
mr_print			ctr_unique_files/OpenDcae-c14
mr_print			ctr_unique_files/OpenDcae-c15
mr_print			ctr_unique_files/OpenDcae-c16

mr_print			ctr_events
mr_print			groups/ctr_events
mr_print			ctr_events/OpenDcae-c12
mr_print			ctr_events/OpenDcae-c13
mr_print			ctr_events/OpenDcae-c14
mr_print			ctr_events/OpenDcae-c15
mr_print			ctr_events/OpenDcae-c16

mr_contain_str		groups						"OpenDcae-c12,OpenDcae-c13,OpenDcae-c14,OpenDcae-c15,OpenDcae-c16"
mr_contain_str		changeids					"PM_MEAS_FILES:CTR_MEAS_FILES,CTR_MEAS_FILES,LOG_FILES,PM_MEAS_FILES:TEST_FILES,TEST_FILES:TEMP_FILES"
mr_contain_str		fileprefixes				$MR_FILE_PREFIX_MAPPING
mr_contain_str		tc_info						"TC#1000"
mr_contain_str		status						"Started"
mr_contain_str		stop						"Stopped"
mr_contain_str		start						"Started"

mr_equal			ctr_requests				0
mr_contain_str		groups/ctr_requests			"0,0,0,0,0"
mr_equal			ctr_requests/OpenDcae-c12	0
mr_equal			ctr_requests/OpenDcae-c13	0
mr_equal			ctr_requests/OpenDcae-c14	0
mr_equal			ctr_requests/OpenDcae-c15	0
mr_equal			ctr_requests/OpenDcae-c16	0

mr_equal			ctr_responses				0
mr_contain_str		groups/ctr_responses		"0,0,0,0,0"
mr_equal			ctr_responses/OpenDcae-c12	0
mr_equal			ctr_responses/OpenDcae-c13	0
mr_equal			ctr_responses/OpenDcae-c14	0
mr_equal			ctr_responses/OpenDcae-c15	0
mr_equal			ctr_responses/OpenDcae-c16	0

mr_equal			ctr_files					0
mr_contain_str		groups/ctr_files			"0,0,0,0,0"
mr_equal			ctr_files/OpenDcae-c12		0
mr_equal			ctr_files/OpenDcae-c13		0
mr_equal			ctr_files/OpenDcae-c14		0
mr_equal			ctr_files/OpenDcae-c15		0
mr_equal			ctr_files/OpenDcae-c16		0

mr_equal			ctr_unique_files				0
mr_contain_str		groups/ctr_unique_files			"0,0,0,0,0"
mr_equal			ctr_unique_files/OpenDcae-c12	0
mr_equal			ctr_unique_files/OpenDcae-c13	0
mr_equal			ctr_unique_files/OpenDcae-c14	0
mr_equal			ctr_unique_files/OpenDcae-c15	0
mr_equal			ctr_unique_files/OpenDcae-c16	0

mr_equal			ctr_events						0
mr_contain_str		groups/ctr_events				"0,0,0,0,0"
mr_equal			ctr_events/OpenDcae-c12			0
mr_equal			ctr_events/OpenDcae-c13			0
mr_equal			ctr_events/OpenDcae-c14			0
mr_equal			ctr_events/OpenDcae-c15			0
mr_equal			ctr_events/OpenDcae-c16			0


dr_print			""
dr_print 			tc_info
dr_print 			execution_time
dr_print 			feeds

dr_print			ctr_publish_query
dr_print			feeds/ctr_publish_query
dr_print 			ctr_publish_query/1
dr_print 			ctr_publish_query/2
dr_print 			ctr_publish_query/3
dr_print 			ctr_publish_query/4
dr_print			ctr_publish_query/5

dr_print			ctr_publish_query_published
dr_print			feeds/ctr_publish_query_published
dr_print			ctr_publish_query_published/1
dr_print			ctr_publish_query_published/2
dr_print			ctr_publish_query_published/3
dr_print			ctr_publish_query_published/4
dr_print			ctr_publish_query_published/5

dr_print			ctr_publish_query_not_published
dr_print			feeds/ctr_publish_query_not_published
dr_print			ctr_publish_query_not_published/1
dr_print			ctr_publish_query_not_published/2
dr_print			ctr_publish_query_not_published/3
dr_print			ctr_publish_query_not_published/4
dr_print			ctr_publish_query_not_published/5

dr_print			ctr_publish_req
dr_print			feeds/ctr_publish_req
dr_print			ctr_publish_req/1
dr_print			ctr_publish_req/2
dr_print			ctr_publish_req/3
dr_print			ctr_publish_req/4
dr_print			ctr_publish_req/5

dr_print			ctr_publish_req_redirect
dr_print			feeds/ctr_publish_req_redirect
dr_print			ctr_publish_req_redirect/1
dr_print			ctr_publish_req_redirect/2
dr_print			ctr_publish_req_redirect/3
dr_print			ctr_publish_req_redirect/4
dr_print			ctr_publish_req_redirect/5

dr_print			ctr_publish_req_published
dr_print			feeds/ctr_publish_req_published
dr_print			ctr_publish_req_published/1
dr_print			ctr_publish_req_published/2
dr_print			ctr_publish_req_published/3
dr_print			ctr_publish_req_published/4
dr_print			ctr_publish_req_published/5

dr_print			ctr_published_files
dr_print			feeds/ctr_published_files
dr_print			ctr_published_files/1
dr_print			ctr_published_files/2
dr_print			ctr_published_files/3
dr_print			ctr_published_files/4
dr_print			ctr_published_files/5

dr_print			ctr_double_publish
dr_print			feeds/ctr_double_publish
dr_print			ctr_double_publish/1
dr_print			ctr_double_publish/2
dr_print			ctr_double_publish/3
dr_print			ctr_double_publish/4
dr_print			ctr_double_publish/5

dr_print			ctr_publish_query_bad_file_prefix
dr_print			feeds/ctr_publish_query_bad_file_prefix
dr_print			ctr_publish_query_bad_file_prefix/1
dr_print			ctr_publish_query_bad_file_prefix/2
dr_print			ctr_publish_query_bad_file_prefix/3
dr_print			ctr_publish_query_bad_file_prefix/4
dr_print			ctr_publish_query_bad_file_prefix/5

dr_print			ctr_publish_req_bad_file_prefix
dr_print			feeds/ctr_publish_req_bad_file_prefix
dr_print			ctr_publish_req_bad_file_prefix/1
dr_print			ctr_publish_req_bad_file_prefix/2
dr_print			ctr_publish_req_bad_file_prefix/3
dr_print			ctr_publish_req_bad_file_prefix/4
dr_print			ctr_publish_req_bad_file_prefix/5






dr_contain_str 		tc_info										"normal"
dr_contain_str 		execution_time								"0:"
dr_contain_str 		feeds										"1:A,2:B,3:C,4:D,5:E"

dr_equal			ctr_publish_query							0
dr_contain_str		feeds/ctr_publish_query						"0,0,0,0,0"
dr_equal 			ctr_publish_query/1							0
dr_equal 			ctr_publish_query/2							0
dr_equal 			ctr_publish_query/3							0
dr_equal 			ctr_publish_query/4							0
dr_equal			ctr_publish_query/5							0

dr_equal			ctr_publish_query_published					0
dr_contain_str		feeds/ctr_publish_query_published			"0,0,0,0,0"
dr_equal			ctr_publish_query_published/1				0
dr_equal			ctr_publish_query_published/2				0
dr_equal			ctr_publish_query_published/3				0
dr_equal			ctr_publish_query_published/4				0
dr_equal			ctr_publish_query_published/5				0

dr_equal			ctr_publish_query_not_published				0
dr_contain_str		feeds/ctr_publish_query_not_published		"0,0,0,0,0"
dr_equal			ctr_publish_query_not_published/1			0
dr_equal			ctr_publish_query_not_published/2			0
dr_equal			ctr_publish_query_not_published/3			0
dr_equal			ctr_publish_query_not_published/4			0
dr_equal			ctr_publish_query_not_published/5			0

dr_equal			ctr_publish_req								0
dr_contain_str		feeds/ctr_publish_req						"0,0,0,0,0"
dr_equal			ctr_publish_req/1							0
dr_equal			ctr_publish_req/2							0
dr_equal			ctr_publish_req/3							0
dr_equal			ctr_publish_req/4							0
dr_equal			ctr_publish_req/5							0

dr_equal			ctr_publish_req_redirect					0
dr_contain_str		feeds/ctr_publish_req_redirect				"0,0,0,0,0"
dr_equal			ctr_publish_req_redirect/1					0
dr_equal			ctr_publish_req_redirect/2					0
dr_equal			ctr_publish_req_redirect/3					0
dr_equal			ctr_publish_req_redirect/4					0
dr_equal			ctr_publish_req_redirect/5					0

dr_equal			ctr_publish_req_published					0
dr_contain_str		feeds/ctr_publish_req_published				"0,0,0,0,0"
dr_equal			ctr_publish_req_published/1					0
dr_equal			ctr_publish_req_published/2					0
dr_equal			ctr_publish_req_published/3					0
dr_equal			ctr_publish_req_published/4					0
dr_equal			ctr_publish_req_published/5					0

dr_equal			ctr_published_files							0
dr_contain_str		feeds/ctr_published_files					"0,0,0,0,0"
dr_equal			ctr_published_files/1						0
dr_equal			ctr_published_files/2						0
dr_equal			ctr_published_files/3						0
dr_equal			ctr_published_files/4						0
dr_equal			ctr_published_files/5						0

dr_equal			ctr_double_publish							0
dr_contain_str		feeds/ctr_double_publish					"0,0,0,0,0"
dr_equal			ctr_double_publish/1						0
dr_equal			ctr_double_publish/2						0
dr_equal			ctr_double_publish/3						0
dr_equal			ctr_double_publish/4						0
dr_equal			ctr_double_publish/5						0

dr_equal			ctr_publish_query_bad_file_prefix			0
dr_contain_str		feeds/ctr_publish_query_bad_file_prefix		"0,0,0,0,0"
dr_equal			ctr_publish_query_bad_file_prefix/1			0
dr_equal			ctr_publish_query_bad_file_prefix/2			0
dr_equal			ctr_publish_query_bad_file_prefix/3			0
dr_equal			ctr_publish_query_bad_file_prefix/4			0
dr_equal			ctr_publish_query_bad_file_prefix/5			0

dr_equal			ctr_publish_req_bad_file_prefix				0
dr_contain_str		feeds/ctr_publish_req_bad_file_prefix		"0,0,0,0,0"
dr_equal			ctr_publish_req_bad_file_prefix/1			0
dr_equal			ctr_publish_req_bad_file_prefix/2			0
dr_equal			ctr_publish_req_bad_file_prefix/3			0
dr_equal			ctr_publish_req_bad_file_prefix/4			0
dr_equal			ctr_publish_req_bad_file_prefix/5			0

drr_print			""
drr_print			tc_info
drr_print			execution_time
drr_print			feeds
drr_print			speed

drr_print			ctr_publish_requests
drr_print			feeds/ctr_publish_requests
drr_print			ctr_publish_requests/1
drr_print			ctr_publish_requests/2
drr_print			ctr_publish_requests/3
drr_print			ctr_publish_requests/4
drr_print			ctr_publish_requests/5

drr_print			ctr_publish_requests_bad_file_prefix
drr_print			feeds/ctr_publish_requests_bad_file_prefix
drr_print			ctr_publish_requests_bad_file_prefix/1
drr_print			ctr_publish_requests_bad_file_prefix/2
drr_print			ctr_publish_requests_bad_file_prefix/3
drr_print			ctr_publish_requests_bad_file_prefix/4
drr_print			ctr_publish_requests_bad_file_prefix/5

drr_print			ctr_publish_responses
drr_print			feeds/ctr_publish_responses
drr_print			ctr_publish_responses/1
drr_print			ctr_publish_responses/2
drr_print			ctr_publish_responses/3
drr_print			ctr_publish_responses/4
drr_print			ctr_publish_responses/5

drr_print			time_lastpublish
drr_print			feeds/time_lastpublish
drr_print			time_lastpublish/1
drr_print			time_lastpublish/2
drr_print			time_lastpublish/3
drr_print			time_lastpublish/4
drr_print			time_lastpublish/5

drr_print			dwl_volume
drr_print			feeds/dwl_volume
drr_print			dwl_volume/1
drr_print			dwl_volume/2
drr_print			dwl_volume/3
drr_print			dwl_volume/4
drr_print			dwl_volume/5


drr_contain_str		tc_info										"normal"
drr_contain_str		execution_time								"0:"
drr_contain_str		feeds										"1:A,2:B,3:C,4:D,5:E"
drr_equal			speed										0

drr_equal			ctr_publish_requests						0
drr_contain_str		feeds/ctr_publish_requests					"0,0,0,0,0"
drr_equal			ctr_publish_requests/1						0
drr_equal			ctr_publish_requests/2						0
drr_equal			ctr_publish_requests/3						0
drr_equal			ctr_publish_requests/4						0
drr_equal			ctr_publish_requests/5						0

drr_equal			ctr_publish_requests_bad_file_prefix		0
drr_contain_str		feeds/ctr_publish_requests_bad_file_prefix	"0,0,0,0,0"
drr_equal			ctr_publish_requests_bad_file_prefix/1		0
drr_equal			ctr_publish_requests_bad_file_prefix/2		0
drr_equal			ctr_publish_requests_bad_file_prefix/3		0
drr_equal			ctr_publish_requests_bad_file_prefix/4		0
drr_equal			ctr_publish_requests_bad_file_prefix/5		0

drr_equal			ctr_publish_responses						0
drr_contain_str		feeds/ctr_publish_responses					"0,0,0,0,0"
drr_equal			ctr_publish_responses/1						0
drr_equal			ctr_publish_responses/2						0
drr_equal			ctr_publish_responses/3						0
drr_equal			ctr_publish_responses/4						0
drr_equal			ctr_publish_responses/5						0

drr_contain_str		time_lastpublish							"--:--"
drr_contain_str		feeds/time_lastpublish						"--:--,--:--,--:--,--:--,--:--"
drr_contain_str		time_lastpublish/1							"--:--"
drr_contain_str		time_lastpublish/2							"--:--"
drr_contain_str		time_lastpublish/3							"--:--"
drr_contain_str		time_lastpublish/4							"--:--"
drr_contain_str		time_lastpublish/5							"--:--"

drr_equal			dwl_volume									0
drr_contain_str		feeds/dwl_volume							"0,0,0,0,0"
drr_equal			dwl_volume/1								0
drr_equal			dwl_volume/2								0
drr_equal			dwl_volume/3								0
drr_equal			dwl_volume/4								0
drr_equal			dwl_volume/5								0










dr_equal            ctr_published_files             0 60

mr_print            tc_info
dr_print            tc_info
drr_print           tc_info

start_dfc 0
start_dfc 1
start_dfc 2
start_dfc 3
start_dfc 4

dr_greater          ctr_published_files             1 60

sleep_wait          30

mr_greater          ctr_requests                    1

mr_greater          ctr_events                      1
mr_greater          ctr_unique_files                1
mr_greater          ctr_unique_PNFs                 1

dr_greater          ctr_publish_query               1
dr_equal            ctr_publish_query_published     0
dr_greater          ctr_publish_query_not_published 1
dr_greater          ctr_publish_req                 1
dr_greater          ctr_publish_req_redirect        1
dr_equal            ctr_publish_req_published       0
dr_greater          ctr_published_files             1
dr_equal            ctr_double_publish              0

drr_greater         ctr_publish_requests            1
drr_greater         ctr_publish_responses           1

drr_greater         dwl_volume                      1000000


####There is a risk of double publishing when running multiple DFCs.
####The related counters ctr_publish_query_published and ctr_double_publish may be non-zero.


check_dfc_logs

#### TEST COMPLETE ####

store_logs          END

print_result
