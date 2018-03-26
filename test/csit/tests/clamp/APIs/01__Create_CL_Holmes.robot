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

Get Requests verify test template found
    ${auth}=    Create List     admin    password
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${resp}=    Get Request    clamp   /restservices/clds/v1/cldsTempate/template-names
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Contain Match     ${resp}      *templateHolmes1*
    Should Contain Match     ${resp}      *templateHolmes2*
    Should Not Contain Match     ${resp}      *templateHolmes99*

Put Requests to add Close Loop ClHolmes1
    ${auth}=    Create List     admin    password
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createClHolmes1.json
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Put Request    clamp   /restservices/clds/v1/clds/model/ClHolmes1     data=${data}   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     200

Put Requests to add Close Loop ClHolmes2
    ${auth}=    Create List     admin    password
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createClHolmes2.json
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Put Request    clamp   /restservices/clds/v1/clds/model/ClHolmes2     data=${data}   headers=${headers}
    Should Be Equal As Strings      ${resp.status_code}     200

Get Requests verify CL1 found
    ${auth}=    Create List     admin    password
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${resp}=    Get Request    clamp   /restservices/clds/v1/clds/model-names
    Should Be Equal As Strings  ${resp.status_code}     200
    Should Contain Match     ${resp}      *ClHolmes1*
    Should Contain Match     ${resp}      *ClHolmes2*
    Should Not Contain Match     ${resp}      *ClHolmes99*
