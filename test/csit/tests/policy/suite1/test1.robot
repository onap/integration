*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary

*** Variables ***
${MESSAGE}    Hello, world!

*** Test Cases ***
Health Test
    [Documentation]    Health Check
    CheckUrl           :6969

*** Keywords ***
CheckDir
    [Arguments]                 ${path}
    Directory Should Exist      ${path}

CheckUrl
    [Arguments]                  ${url}
    Log To Console    ${url}
    ${auth}=    Create List    healthcheck    zb!XztG34
    Log To Console    ${auth}
    ${headers}=    Create Dictionary     Accept=application/json    Content-Type=application/json
    Log To Console    ${headers}
    ${session}=    Create Session    session    ${url}    auth=${auth}
    ${resp}= 	Get Request 	session    /healthcheck     headers=${headers}
    Log To Console    Received response from policy ${resp.text}
    Should Not Be Empty    ${url}


***    Should Be Equal As Integers  ${resp.status_code}  200 ***
