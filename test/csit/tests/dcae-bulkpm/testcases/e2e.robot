*** Settings ***
Documentation	  Testing E2E VES,Dmaap,DFC,DR with File Ready event feed from xNF
Library 	      RequestsLibrary   
Library           OperatingSystem
Library           Collections
Resource          resources/ves_keywords.robot


*** Variables ***
${VESC_URL}                              http://%{VESC_IP}:8080 
${GLOBAL_APPLICATION_ID}                 robot-ves
${VES_ANY_EVENT_PATH}                    /eventListener/v7
${HEADER_STRING}                         content-type=application/json
${EVENT_DATA_FILE}                       %{WORKSPACE}/test/csit/tests/dcae-bulkpm/testcases/assets/json_events/FileExistNotification.json

${TARGETURL_TOPICS}                      http://${DMAAP_MR_IP}:3904/topics
${TARGETURL_SUBSCR}                      http://${DMAAP_MR_IP}:3904/events/TestTopic1/CG1/C1?timeout=1000
${TEST_DATA}                             {"topicName": "TestTopic1"}
${TOPIC_DATA}                            {"topicName":"FirstTopic","topicDescription":"This is a TestTopic","partitionCount":"1","replicationCount":"3","transactionEnabled":"true"}

*** Test Cases ***    

Send VES File Ready Event to VES Collector
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event and expect 200 Response 
    ${evtdata}=   Get Event Data From File   ${EVENT_DATA_FILE}
    ${headers}=   Create Header From String    ${HEADER_STRING}
    ${resp}=  Publish Event To VES Collector    ${VESC_URL}  ${VES_ANY_EVENT_PATH}  ${headers}  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	202
   
Check VES Notification Topic is exisiting in Message Router
    [Documentation]    		  		Get the count of the Topics
    [Timeout]    			  		1 minute
    ${resp}=    			  		GetCall                       	${TARGETURL_TOPICS}
    log              		  		${TARGETURL_TOPICS}
    log    				  			'JSON Response Code :'${resp}
    ${topics}=       			  	Evaluate                 	  	$resp.json().get('topics')
    log					  			${topics}
    ${ListLength}=    			  	Get Length                    	${topics}
    log    				  			${ListLength}
    List Should Contain Value 		${topics}                       unauthenticated.VES_NOTIFICATION_OUTPUT
