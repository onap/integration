*** Settings ***
Documentation	  Testing DCAE VES Listener with various event feeds from VoLTE, vDNS, vFW and cCPE use scenarios

Library 	      RequestsLibrary   
Library           OperatingSystem
Library           Collections
Library           DcaeLibrary
Resource          resources/dcae_keywords.robot
Test Setup        Cleanup VES Events
Suite Setup       VES Collector Suite Setup DMaaP
Suite Teardown    VES Collector Suite Shutdown DMaaP    




*** Variables ***
${VESC_URL_HTTPS}                        https://%{VESC_IP}:8443
${VESC_URL}                              http://%{VESC_IP}:8080
${VES_ANY_EVENT_PATH}                    /eventListener/v5
${VES_BATCH_EVENT_PATH}             	 /eventListener/v5/eventBatch
${VES_THROTTLE_STATE_EVENT_PATH}         /eventListener/v5/clientThrottlingState
${HEADER_STRING}                         content-type=application/json
${EVENT_DATA_FILE}                       %{WORKSPACE}/test/csit/tests/dcaegen2/testcases/assets/json_events/ves_volte_single_fault_event.json
${EVENT_MEASURE_FILE}                    %{WORKSPACE}/test/csit/tests/dcaegen2/testcases/assets/json_events/ves_vfirewall_measurement.json
${EVENT_DATA_FILE_BAD}                   %{WORKSPACE}/test/csit/tests/dcaegen2/testcases/assets/json_events/ves_volte_single_fault_event_bad.json
${EVENT_BATCH_DATA_FILE}                 %{WORKSPACE}/test/csit/tests/dcaegen2/testcases/assets/json_events/ves_volte_fault_eventlist_batch.json
${EVENT_THROTTLING_STATE_DATA_FILE}      %{WORKSPACE}/test/csit/tests/dcaegen2/testcases/assets/json_events/ves_volte_fault_provide_throttle_state.json


#DCAE Health Check
${CONFIG_BINDING_URL}                    http://localhost:8443
${CB_HEALTHCHECK_PATH}                   /healthcheck
${CB_SERVICE_COMPONENT_PATH}             /service_component/
${VES_Service_Name1}                     dcae-controller-ves-collector
${VES_Service_Name2}                     ves-collector-not-exist

*** Comment out from R1 release ***
DCAE Health Check
    [Tags]    DCAE-HealthCheck
    [Documentation]   Get DCAE Overall Status
    ${auth}=  Create List  ${GLOBAL_DCAE_USERNAME}  ${GLOBAL_DCAE_PASSWORD}
    ${session}=    Create Session 	dcae-health-check 	${CONFIG_BINDING_URL}    auth=${auth}
    ${resp}= 	Get Request 	dcae-health-check 	${CB_HEALTHCHECK_PATH}
    Should Be Equal As Strings 	${resp.status_code} 	200


Get VES Collector Service Status
    [Tags]    DCAE-HealthCheck
    [Documentation]   Get the status of a VES Collector Service Component based on service name
    ${urlpath}=    Catenate  SEPARATOR= ${CB_SERVICE_COMPONENT_PATH} ${VES_Service_Name1}
    Log   Service component name for status query: ${urlpath}
    ${resp}=  Get DCAE Service Component Status   ${CONFIG_BINDING_URL}  ${CB_SERVICE_COMPONENT_PATH}  ${GLOBAL_DCAE_USERNAME}  ${GLOBAL_DCAE_PASSWORD}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	200
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
    
    
    
#*** Comment out from R1 release ***
Publish VES VoLTE Fault Provide Throttling State
    [Tags]    DCAE-D1
    ${evtdata}=   Get Event Data From File   ${EVENT_THROTTLING_STATE_DATA_FILE}
    ${headers}=   Create Header From String    ${HEADER_STRING}
    ${resp}=  Publish Event To VES Collector    ${VES_VOLTE_URL}  ${VES_THROTTLE_STATE_EVENT_PATH}  ${headers}  ${evtdata}  ${GLOBAL_DCAE_USERNAME}  ${GLOBAL_DCAE_PASSWORD}
    Should Be Equal As Strings 	${resp.status_code} 	204
    
Publish VES Event With Invalid Method
    [Tags]    DCAE-D1
    [Documentation]    Use invalid Put instead of Post method to expect 405 response
    ${evtdata}=   Get Event Data From File   ${EVENT_DATA_FILE}
    ${headers}=   Create Header From String    ${HEADER_STRING}
    Log   Send HTTP Request with invalid method Put instead of Post
    ${resp}=  Publish Event To VES Collector With Put Method   ${VES_VOLTE_URL}  ${VES_ANY_EVENT_PATH}  ${headers}  ${evtdata}  ${GLOBAL_DCAE_USERNAME}  ${GLOBAL_DCAE_PASSWORD}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	405
    
    
Publish VES Event With Invalid URL Path
    [Tags]    DCAE-D1
    [Documentation]    Use invalid url path to expect 404 response
    ${evtdata}=   Get Event Data From File   ${EVENT_DATA_FILE}
    ${headers}=   Create Header From String    ${HEADER_STRING}
    Log   Send HTTP Request with invalid /listener/v5/ instead of /eventlistener/v5 path
    ${resp}=  Publish Event To VES Collector    ${VES_VOLTE_URL}  /listener/v5/  ${headers}  ${evtdata}  ${GLOBAL_DCAE_USERNAME}  ${GLOBAL_DCAE_PASSWORD}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	404

Publish VES Event With Invalid Login
    [Tags]    DCAE-D1
    [Documentation]    Use invalid user or password to expect 401 response
    ${evtdata}=   Get Event Data From File   ${EVENT_DATA_FILE}
    ${headers}=   Create Header From String    ${HEADER_STRING}
    Log   Send HTTP Request with invalid User: BadUserName
    ${resp}=  Publish Event To VES Collector    ${VES_VOLTE_URL}  ${VES_ANY_EVENT_PATH}  ${headers}  ${evtdata}  BadUserName  ${GLOBAL_DCAE_PASSWORD}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	401
    
*** Test Cases ***
VES Collector Health Check
    [Tags]    DCAE-VESC-R1
    [Documentation]   Ves Collector Health Check
    ${uuid}=    Generate UUID
    ${session}=    Create Session 	dcae 	${VESC_URL}
    ${headers}=  Create Dictionary     Accept=*/*     X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	dcae 	/healthcheck        headers=${headers}
    Should Be Equal As Strings 	${resp.status_code} 	200
    

Publish Single VES VoLTE Fault Event
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event and expect 200 Response 
    ${evtdata}=   Get Event Data From File   ${EVENT_DATA_FILE}
    ${headers}=   Create Header From String    ${HEADER_STRING}
    ${resp}=  Publish Event To VES Collector No Auth    ${VESC_URL}  ${VES_ANY_EVENT_PATH}  ${headers}  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	200
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
    ${ret}=  DMaaP Message Receive    ab305d54-85b4-a31b-7db2-fb6b9e546015
    Should Be Equal As Strings    ${ret}    true

Publish Single VES VNF Measurement Event
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post single event and expect 200 Response 
    ${evtdata}=   Get Event Data From File   ${EVENT_MEASURE_FILE}
    ${headers}=   Create Header From String    ${HEADER_STRING}
    ${resp}=  Publish Event To VES Collector No Auth    ${VESC_URL}   ${VES_ANY_EVENT_PATH}  ${headers}  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	200
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
    ${ret}=  DMaaP Message Receive    0b2b5790-3673-480a-a4bd-5a00b88e5af6
    Should Be Equal As Strings    ${ret}    true

Publish VES VoLTE Fault Batch Events
    [Tags]    DCAE-VESC-R1
    [Documentation]   Post batched events and expect 202 Response 
    ${evtdata}=   Get Event Data From File   ${EVENT_BATCH_DATA_FILE}
    ${headers}=   Create Header From String    ${HEADER_STRING}
    ${resp}=  Publish Event To VES Collector No Auth    ${VESC_URL}  ${VES_BATCH_EVENT_PATH}  ${headers}  ${evtdata}
    Should Be Equal As Strings 	${resp.status_code} 	200
    ${ret}=  DMaaP Message Receive    ab305d54-85b4-a31b-7db2-fb6b9e546016
    Should Be Equal As Strings    ${ret}    true    
    
    
Publish Single VES VoLTE Fault Event With Bad Data
    [Tags]    DCAE-VESC-R1
    [Documentation]    Run with JSON Envent with missing comma to expect 400 response
    ${evtdata}=   Get Event Data From File   ${EVENT_DATA_FILE_BAD}
    ${headers}=   Create Header From String    ${HEADER_STRING}  
    Log   Send HTTP Request with invalid Json Event Data
    ${resp}=  Publish Event To VES Collector No Auth    ${VESC_URL}  ${VES_ANY_EVENT_PATH}  ${headers}  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	400
    ${isEmpty}=   Is Json Empty    ${resp}
    Run Keyword If   '${isEmpty}' == False   Log  ${resp.json()}
    
Publish VES Event With Invalid Method
    [Tags]    DCAE-VESC-R1
    [Documentation]    Use invalid Put instead of Post method to expect 405 response
    ${evtdata}=   Get Event Data From File   ${EVENT_DATA_FILE}
    ${headers}=   Create Header From String    ${HEADER_STRING}
    Log   Send HTTP Request with invalid method Put instead of Post
    ${resp}=  Publish Event To VES Collector With Put Method No Auth  ${VESC_URL}  ${VES_ANY_EVENT_PATH}  ${headers}  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	404
    
    
Publish VES Event With Invalid URL Path
    [Tags]    DCAE-VESC-R1
    [Documentation]    Use invalid url path to expect 404 response
    ${evtdata}=   Get Event Data From File   ${EVENT_DATA_FILE}
    ${headers}=   Create Header From String    ${HEADER_STRING}
    Log   Send HTTP Request with invalid /listener/v5/ instead of /eventListener/v5 path
    ${resp}=  Publish Event To VES Collector No Auth    ${VESC_URL}  /listener/v5/  ${headers}  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	404
    

    
        
    
  
    
  


