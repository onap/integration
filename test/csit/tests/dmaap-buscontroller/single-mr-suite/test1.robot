*** Settings ***
Resource          ../../common.robot
Library           Collections
Library           json
Library           OperatingSystem
Library           RequestsLibrary



*** Variables ***
${MESSAGE}    Hello, world!
${DBC_URI}    webapi
${TOPIC1}     singleMRtopic1
${TOPIC1_DATA} 	{ "topicName":"singleMRtopic1", "topicDescription":"generated for CSIT", "owner":"dgl"}



*** Test Cases ***
Url Test
    [Documentation]    Check if www.onap.org can be reached
    Create Session     sanity          http://onap.readthedocs.io
    ${resp}=           Get Request   sanity    /  
    Should Be Equal As Integers  ${resp.status_code}  200

Create Topic Test
    [Documentation]        Check POST ${DBC_URI}/topics endpoint
    ${resp}=         PostCall    http://${DMAAPBC_IP}:8080/${DBC_URI}/topics    ${TOPIC1_DATA}
    Should Be Equal As Integers  ${resp.status_code}  201

*** Keywords ***
CheckDir
    [Arguments]                 ${path}
    Directory Should Exist      ${path}

CheckUrl
    [Arguments]                  ${session}   ${path}     ${expect}
    ${resp}=                     Get  Request          ${session} ${path} 
    Should Be Equal As Integers  ${resp.status_code}  ${expect}

PostCall
    [Arguments]    ${url}           ${data}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=       Evaluate    requests.post('${url}',data='${data}', headers=${headers},verify=False)    requests
    [Return]       ${resp}

