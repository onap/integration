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

Put Requests to add Holmes template1 without properties
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createHolmesTemplate1.json
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Put Request    clamp   /restservices/clds/v1/cldsTempate/template/HolmesTemplate1     data=${data}   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     200

Put Requests to add Holmes template2 without properties
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createHolmesTemplate2.json
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Put Request    clamp   /restservices/clds/v1/cldsTempate/template/HolmesTemplate2     data=${data}   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     200

Get Requests verify Holmes template1 and template2 found
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${resp}=    Get Request    clamp   /restservices/clds/v1/cldsTempate/template-names
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Contain Match     ${resp}      *HolmesTemplate1*
    Should Contain Match     ${resp}      *HolmesTemplate2*
    Should Not Contain Match     ${resp}      *HolmesTemplate99*

Put Requests to add Close Loop Holmes Model1
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createHolmesModel1.json
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Put Request    clamp   /restservices/clds/v1/clds/model/HolmesModel1     data=${data}   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     200

Get Requests verify Holmes Model1 found
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${resp}=    Get Request    clamp   /restservices/clds/v1/clds/model-names
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Contain Match     ${resp}      *HolmesModel1*
    Should Not Contain Match     ${resp}      *HolmesModel99*
