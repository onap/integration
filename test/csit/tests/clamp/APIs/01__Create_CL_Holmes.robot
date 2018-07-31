*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${login}                     admin
${passw}                     password

*** Keywords ***
Create the sessions
    ${auth}=    Create List     ${login}    ${passw}
    Create Session   clamp  https://localhost:8443   auth=${auth}   disable_warnings=1
    Set Global Variable     ${clamp_session}      clamp

*** Test Cases ***
Get Requests health check ok
    Create the sessions
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/healthcheck
    Should Be Equal As Strings  ${resp.status_code}     200

Get Requests verify test template found
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/cldsTempate/template-names
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Contain Match     ${resp}      *templateHolmes1*
    Should Contain Match     ${resp}      *templateHolmes2*
    Should Not Contain Match     ${resp}      *templateHolmes99*

Put Requests to add Close Loop ClHolmes1
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createClHolmes1.json
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Put Request    ${clamp_session}   /restservices/clds/v1/clds/model/ClHolmes1     data=${data}   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     200

Put Requests to add Close Loop ClHolmes2
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createClHolmes2.json
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Put Request    ${clamp_session}   /restservices/clds/v1/clds/model/ClHolmes2     data=${data}   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     200

Get Requests verify CL1 found
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/clds/model-names
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Contain Match     ${resp}      *ClHolmes1*
    Should Contain Match     ${resp}      *ClHolmes2*
    Should Not Contain Match     ${resp}      *ClHolmes99*
