*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     String

*** Variables ***
${SDN_APIDOCS_URI}    /apidoc/apis
${SDN_HEALTHCHECK_OPERATION_PATH}    /operations/SLI-API:healthcheck
${PRELOAD_VNF_TOPOLOGY_OPERATION_PATH}  /operations/VNF-API:preload-vnf-topology-operation

*** Test Cases ***

Healthcheck API
    Create Session   sdnc  http://localhost:8282/restconf
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}data.json
    &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46YWRtaW4=    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    sdnc    ${SDN_HEALTHCHECK_OPERATION_PATH}    data=${data}    headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['output']['response-code']}   200
	
Check SLI-API
    Create Session   sdnc  http://localhost:8282
    &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46YWRtaW4=    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    sdnc    ${SDN_APIDOCS_URI}    headers=${headers}
    Log    ${resp.content}
    Should Contain    ${resp.content}    SLI-API  

Check VNF-API
    Create Session   sdnc  http://localhost:8282
    &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46YWRtaW4=    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    sdnc    ${SDN_APIDOCS_URI}    headers=${headers}
    Log    ${resp.content}
    Should Contain    ${resp.content}    VNF-API

Test Preload
    Create Session   sdnc  http://localhost:8282/restconf
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}preload.json
    &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46YWRtaW4=    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    sdnc    ${PRELOAD_VNF_TOPOLOGY_OPERATION_PATH}    data=${data}    headers=${headers}
    Log    ${resp.content}
    Should Be Equal As Strings    ${resp.status_code}    200
    Should Be Equal As Strings  ${resp.json()['output']['response-code']}   200

