*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json


*** Test Cases ***
Get Requests health check ok
    CreateSession   clamp  http://localhost:8080
    ${resp}=    Get Request    clamp   /restservices/clds/v1/clds/healthcheck
    Should Be Equal As Strings  ${resp.status_code}     200

Put Requests to add TCA template1 with yaml properties
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createTCATemplate1.json
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Put Request    clamp   /restservices/clds/v1/cldsTempate/template/TCATemplate1     data=${data}   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     200

Put Requests to add TCA template2 with yaml properties
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createTCATemplate2.json
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Put Request    clamp   /restservices/clds/v1/cldsTempate/template/TCATemplate2     data=${data}   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     200

Get Requests verify TCA template1 and template2 found
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${resp}=    Get Request    clamp   /restservices/clds/v1/cldsTempate/template-names
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Contain Match     ${resp}      *TCATemplate1*
    Should Contain Match     ${resp}      *TCATemplate2*
    Should Not Contain Match     ${resp}      *TCATemplate99*

Put Requests to add Close Loop TCA Model1
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createTCAModel1.json
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Put Request    clamp   /restservices/clds/v1/clds/model/TCAModel1     data=${data}   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     200

Get Requests verify TCA Model1 found
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${resp}=    Get Request    clamp   /restservices/clds/v1/clds/model-names
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Contain Match     ${resp}      *TCAModel1*
    Should Not Contain Match     ${resp}      *TCAModel99*
