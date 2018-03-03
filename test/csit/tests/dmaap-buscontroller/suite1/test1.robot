*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary

*** Variables ***
${MESSAGE}    Hello, world!
${DBC_URI}    /webapi

*** Test Cases ***
String Equality Test
    Should Be Equal    ${MESSAGE}    Hello, world!

Dir Test
    [Documentation]    Check if /tmp exists
    Log                ${MESSAGE}
    CheckDir           /tmp

Url Test
    [Documentation]    Check if www.onap.org can be reached
    Create Session     openo          http://www.onap.org
    CheckUrl           openo          /                        200

Mock Hello Server Test
    [Documentation]        Check /hello endpoint
    Create Session         hello              http://${AAF_IP}:1080
    CheckUrl               hello              /hello           200

Heartbeat Test
    [Documentation]        Check ${DBC_URI}/info endpoint
    Create Session         heartbeat          http://${DMAAPBC_IP}:8080
    CheckUrl               heartbeat          ${DBC_URI}/info   204

*** Keywords ***
CheckDir
    [Arguments]                 ${path}
    Directory Should Exist      ${path}

CheckUrl
    [Arguments]                  ${session}   ${path}     ${expect}
    ${resp}=                     Get Request          ${session}               ${path}
    Should Be Equal As Integers  ${resp.status_code}  ${expect}

