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

Put Requests to add Holmes template1 with yaml properties
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createHolmesTemplate1.json
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Put Request    clamp   /restservices/clds/v1/cldsTempate/template/HolmesTemplate1     data=${data}   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     200

Put Requests to add Holmes template2 with yaml properties
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

