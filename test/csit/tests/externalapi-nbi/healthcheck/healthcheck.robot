*** Settings ***
Documentation     The main interface for interacting with External API/NBI
Library           RequestsLibrary
Library           Collections

*** Variables ***
${GLOBAL_NBI_SERVER_PROTOCOL}   http
${GLOBAL_INJECTED_NBI_IP_ADDR}  localhost
${GLOBAL_NBI_SERVER_PORT}       8080
${NBI_HEALTH_CHECK_PATH}        /nbi/api/v3/status
${NBI_ENDPOINT}                 ${GLOBAL_NBI_SERVER_PROTOCOL}://${GLOBAL_INJECTED_NBI_IP_ADDR}:${GLOBAL_NBI_SERVER_PORT}

*** Test Cases ***
NBI Health Check
    Run NBI Health Check

*** Keywords ***
Run NBI Health Check
     [Documentation]    Runs NBI Health check
     ${resp}=    Run NBI Get Request    ${NBI_HEALTH_CHECK_PATH}
     Should Be Equal As Integers   ${resp.status_code}   200

Run NBI Get Request
     [Documentation]    Runs NBI Get request
     [Arguments]    ${data_path}
     ${session}=    Create Session   session   ${NBI_ENDPOINT}
     ${resp}=   Get Request   session   ${data_path}
     Should Be Equal As Integers   ${resp.status_code}   200
     Log    Received response from NBI ${resp.text}
     ${json}=    Set Variable    ${resp.json()}
     ${status}=    Get From Dictionary    ${json}   status
     Should Be Equal  ${status}    ok
     [Return]    ${resp}
