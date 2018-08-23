*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       HttpLibrary.HTTP
Library       Collections
Library       String

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

HTTPS Heartbeat Test
    [Documentation]        Check ${DBC_URI}/info SSL endpoint
    Create Session         heartbeat          https://${DMAAPBC_IP}:8443
    CheckUrl               heartbeat          ${DBC_URI}/info   204

HTTPS Dmaap Init Test
    [Documentation]        Check ${DBC_URI}/dmaap SSL endpoint
    Create Session         heartbeat          https://${DMAAPBC_IP}:8443
    CheckStatus               heartbeat          ${DBC_URI}/dmaap   "VALID"

HTTPS Dmaap dcaeLocations Test
    [Documentation]        Check ${DBC_URI}/dcaeLocations SSL endpoint
    Create Session         heartbeat          https://${DMAAPBC_IP}:8443
    CheckStatus0               heartbeat          ${DBC_URI}/dcaeLocations   "VALID"

HTTPS Dmaap mr_clusters Test
    [Documentation]        Check ${DBC_URI}/mr_clusters SSL endpoint
    Create Session         heartbeat          https://${DMAAPBC_IP}:8443
    CheckStatus0               heartbeat          ${DBC_URI}/mr_clusters   "VALID"


*** Keywords ***
CheckDir
    [Arguments]                 ${path}
    Directory Should Exist      ${path}

CheckUrl
    [Arguments]                  ${session}   ${path}     ${expect}
    ${resp}=                     Get Request          ${session}               ${path}
    Should Be Equal As Integers  ${resp.status_code}  ${expect}

CheckStatus
    [Arguments]                  ${session}   ${path}     ${expect}
    ${resp}=                     Get Request          ${session}               ${path}
    log                          ${resp.content}
    ${val}=                      Get Json value       ${resp.content}     /status
    log                          ${val}
    should be equal as strings   ${val}      ${expect}

CheckStatus0
    [Arguments]                  ${session}   ${path}     ${expect}
    ${resp}=                     Get Request          ${session}               ${path}
    log                          ${resp.json()}
    log                          ${resp.content}
# silliness to strip off the brackets returned for a List to get a Dict
    ${t1}=                       Remove String       ${resp.content}       [
    ${dict}=                     Remove String       ${t1}                 ]
    log                          ${dict}
    ${val}=                      Get Json value       ${dict}     /status
    log                          ${val}
    should be equal as strings   ${val}      ${expect}

