*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary

*** Variables ***
${MESSAGE}    Hello, world!

*** Test Cases ***
String Equality Test
    Should Be Equal    ${MESSAGE}    Hello, world!

Dir Test
    [Documentation]    Check if /tmp exists
    Log                ${MESSAGE}
    CheckDir           /tmp

Url Test
    [Documentation]    Check if www.open-o.org can be reached
    Create Session     openo          http://www.open-o.org
    CheckUrl           openo          /

Mock Hello Server Test
    [Documentation]        Check /hello endpoint
    Create Session         hello              http://${MOCK_IP}:1080
    CheckUrl               hello              /hello

*** Keywords ***
CheckDir
    [Arguments]                 ${path}
    Directory Should Exist      ${path}

CheckUrl
    [Arguments]                  ${session}   ${path}
    ${resp}=                     Get Request          ${session}               ${path}
    Should Be Equal As Integers  ${resp.status_code}  200
