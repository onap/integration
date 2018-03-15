*** Settings ***
Library       RequestsLibrary

*** Test Cases ***
Liveness Test
    [Documentation]        Check various endpoints for basic liveness check
    Create Session         esr-server              https://${ESRSERVER_IP}:9518
    CheckUrl               esr-server              /api/aai-esr-server/v1/test

*** Keywords ***
CheckUrl
    [Arguments]                   ${session}  ${path}
    ${resp}=                      Get Request          ${session}  ${path}
    Should Be Equal As Integers   ${resp.status_code}  200

