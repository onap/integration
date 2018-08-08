*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${login}                     admin
${passw}                     password

*** Test Cases ***
Get Requests health check ok
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/healthcheck
    Should Be Equal As Strings  ${resp.status_code}     200

Get Requests verify test template found
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/cldsTempate/template-names
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Contain Match     ${resp}      *templateTCA1*
    Should Contain Match     ${resp}      *CA2*
    Should Not Contain Match     ${resp}      *templateTCA99*

Put Requests to add Close Loop ClHolmes1
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createClTCA1.json
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Put Request    ${clamp_session}   /restservices/clds/v1/clds/model/ClTCA1    data=${data}   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     200

Put Requests to add Close Loop ClHolmes2
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createClTCA2.json
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Put Request    ${clamp_session}   /restservices/clds/v1/clds/model/ClTCA2     data=${data}   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     200

Get Requests verify CL1 found
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/clds/model-names
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Contain Match     ${resp}      *ClTCA1*
    Should Contain Match     ${resp}      *ClTCA2*
    Should Not Contain Match     ${resp}      *ClTCA99*
