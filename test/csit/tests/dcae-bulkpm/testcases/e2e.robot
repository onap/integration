*** Settings ***
Documentation	  Testing E2E VES,Dmaap,DFC,DR with File Ready event feed from xNF
Library           RequestsLibrary
Library           OperatingSystem
Library           Collections
Library           Process
Resource          resources/ves_keywords.robot


*** Variables ***
${VESC_URL}                              http://%{VESC_IP}:8080
${GLOBAL_APPLICATION_ID}                 robot-ves
${VES_ANY_EVENT_PATH}                    /eventListener/v7
${HEADER_STRING}                         content-type=application/json
${EVENT_DATA_FILE}                       %{WORKSPACE}/test/csit/tests/dcae-bulkpm/testcases/assets/json_events/FileExistNotificationUpdated.json

${TARGETURL_TOPICS}                      http://${DMAAP_MR_IP}:3904/topics
${TARGETURL_SUBSCR}                      http://${DMAAP_MR_IP}:3904/events/unauthenticated.VES_NOTIFICATION_OUTPUT/OpenDcae-c12/C12?timeout=1000
${CLI_EXEC_CLI}                          curl -k https://${DR_PROV_IP}:8443/internal/prov
${CLI_EXEC_CLI_DFC}                      docker exec dfc /bin/sh -c "ls /target | grep .gz"

*** Test Cases ***

Send VES File Ready Event to VES Collector
    [Tags]    Bulk_PM_E2E_01
    [Documentation]   Send VES File Ready Event
    ${evtdata}=   Get Event Data From File   ${EVENT_DATA_FILE}
    ${headers}=   Create Header From String    ${HEADER_STRING}
    ${resp}=  Publish Event To VES Collector    ${VESC_URL}  ${VES_ANY_EVENT_PATH}  ${headers}  ${evtdata}
    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings 	${resp.status_code} 	202

Check VES Notification Topic is existing in Message Router
    [Tags]                          Bulk_PM_E2E_02
    [Documentation]                 Get the VES Notification topic on message router
    [Timeout]                       1 minute
    Sleep                           10s
    ${resp}=                        GetCall                         ${TARGETURL_TOPICS}
    log                             ${TARGETURL_TOPICS}
    log                             'JSON Response Code :'${resp}
    ${topics}=                      Evaluate                        $resp.json().get('topics')
    log                             ${topics}
    ${ListLength}=                  Get Length                      ${topics}
    log                             ${ListLength}
    List Should Contain Value       ${topics}                       unauthenticated.VES_NOTIFICATION_OUTPUT

Verify Downloaded PM file from xNF exist on Data File Collector
    [Tags]              Bulk_PM_E2E_03
    [Documentation]     Check the PM XML file exists on the File Consumer Simulator
    ${cli_cmd_output}=    Run Process   ${CLI_EXEC_CLI_DFC}    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    0
    Should Contain    ${cli_cmd_output.stdout}    xNF.pm.xml.gz


Verify Default Feed And File Consumer Subscription On Datarouter
    [Tags]              Bulk_PM_E2E_04
    [Documentation]     Verify Default Feed And File Consumer Subscription On Datarouter
    ${cli_cmd_output}=    Run Process   ${CLI_EXEC_CLI}    shell=yes
    Log    ${cli_cmd_output.stdout}
    Should Be Equal As Strings    ${cli_cmd_output.rc}    0
    Should Contain    ${cli_cmd_output.stdout}    https://dmaap-dr-prov/publish/1
    Should Contain    ${cli_cmd_output.stdout}    http://${DR_SUBSCIBER_IP}:7070