*** Settings ***
Library       RequestsLibrary

*** Test Cases ***
Liveness Test
    [Documentation]        Check various endpoints for basic liveness check
    Create Session         msb              http://${MSB_IAG_IP}:80
    CheckUrl               msb              /msb
    CheckUrl               msb              /iui/microservices/default.html

*** Keywords ***
CheckUrl
    [Arguments]                   ${session}  ${path}
    ${resp}=                      Get Request          ${session}  ${path}
    Should Be Equal As Integers   ${resp.status_code}  200

