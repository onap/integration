*** Settings ***
Resource          ../../common.robot
Library           Collections
Library           json
Library           OperatingSystem
Library           RequestsLibrary
Library           HttpLibrary.HTTP
Library           String


*** Variables ***
${MESSAGE}    Hello, world!
${DBC_URI}    webapi
${DBC_URL}    http://${DMAAPBC_IP}:8080/${DBC_URI}
${LOC}          csit-sanfrancisco
${PUB_CORE}     "dcaeLocationName": "${LOC}", "clientRole": "org.onap.dmaap.client.pub", "action": [ "pub", "view" ] 
${SUB_CORE}     "dcaeLocationName": "${LOC}", "clientRole": "org.onap.dmaap.client.sub", "action": [ "sub", "view" ] 
${PUB}          { ${PUB_CORE} }
${SUB}          { ${SUB_CORE} }
${FEED1_DATA}  { "feedName":"feed1", "feedVersion": "csit", "feedDescription":"generated for CSIT", "owner":"dgl", "asprClassification": "unclassified" }
${FEED2_DATA}  { "feedName":"feed2", "feedVersion": "csit", "feedDescription":"generated for CSIT", "owner":"dgl", "asprClassification": "unclassified" }
${PUB2_DATA}   { "dcaeLocationName": "${LOC}", "username": "pub2", "userpwd": "topSecret123", "feedId": "2" }
${SUB2_DATA}   { "dcaeLocationName": "${LOC}", "username": "sub2", "userpwd": "someSecret123", "deliveryURL": "https://${DMAAPBC_IP}:8443/webapi/noURI", "feedId": "2" }
${TOPIC2_DATA}  { "topicName":"singleMRtopic2", "topicDescription":"generated for CSIT", "owner":"dgl", "clients": [ ${PUB}, ${SUB}] }
${TOPIC3_DATA}  { "topicName":"singleMRtopic3", "topicDescription":"generated for CSIT", "owner":"dgl"}
#${PUB3_DATA}    { "fqtn": "${TOPIC_NS}.singleMRtopic3", ${PUB_CORE} }
#${SUB3_DATA}    { "fqtn": "${TOPIC_NS}.singleMRtopic3", ${SUB_CORE} }



*** Test Cases ***
Url Test
    [Documentation]    Check if www.onap.org can be reached
    Create Session     sanity          http://onap.readthedocs.io
    ${resp}=           Get Request   sanity    /  
    Should Be Equal As Integers  ${resp.status_code}  200

(DMAAP-441c1)
    [Documentation]        Create Feed w no clients POST ${DBC_URI}/feeds endpoint
    ${resp}=         PostCall    ${DBC_URL}/feeds    ${FEED1_DATA}
    Should Be Equal As Integers  ${resp.status_code}  200   

(DMAAP-441c2)
    [Documentation]        Create Feed w clients POST ${DBC_URI}/feeds endpoint
    ${resp}=         PostCall    ${DBC_URL}/feeds    ${FEED2_DATA}
    Should Be Equal As Integers  ${resp.status_code}  200   

(DMAAP-441c3)
    [Documentation]        Add Publisher to existing feed
    ${resp}=         PostCall    ${DBC_URL}/dr_pubs    ${PUB2_DATA}
    Should Be Equal As Integers  ${resp.status_code}  201   
    ${tmp}=          Get Json Value      ${resp.text}           /pubId
    ${tmp}=          Remove String       ${tmp}         \"
    Set Suite Variable          ${pubId}    ${tmp}

(DMAAP-441c4)
    [Documentation]        Add Subscriber to existing feed
    ${resp}=         PostCall    ${DBC_URL}/dr_subs    ${SUB2_DATA}
    Should Be Equal As Integers  ${resp.status_code}  201   
    ${tmp}=          Get Json Value      ${resp.text}           /subId
    ${tmp}=          Remove String       ${tmp}         \"
    Set Suite Variable          ${subId}    ${tmp}

(DMAAP-443)
    [Documentation]        List existing feeds
    Create Session     get          ${DBC_URL}
    ${resp}=         Get Request    get       /feeds
    Should Be Equal As Integers  ${resp.status_code}  200

(DMAAP-444)
    [Documentation]        Delete existing subscriber
    ${resp}=         DelCall    ${DBC_URL}/dr_subs/${subId}
    Should Be Equal As Integers  ${resp.status_code}  204

(DMAAP-445)
    [Documentation]        Delete existing publisher
    ${resp}=         DelCall    ${DBC_URL}/dr_pubs/${pubId}
    Should Be Equal As Integers  ${resp.status_code}  204

#(DMAAP-294)
#    [Documentation]        Create Topic w pub and sub clients POST ${DBC_URI}/topics endpoint
#    ${resp}=         PostCall    ${DBC_URL}/topics    ${TOPIC2_DATA}
#    Should Be Equal As Integers  ${resp.status_code}  201
#
#(DMAAP-295)
#    [Documentation]        Create Topic w no clients and then add a client POST ${DBC_URI}/mr_clients endpoint
#    ${resp}=         PostCall    ${DBC_URL}/topics    ${TOPIC3_DATA}
#    Should Be Equal As Integers  ${resp.status_code}  201   
#    ${resp}=         PostCall    ${DBC_URL}/mr_clients    ${PUB3_DATA}
#    Should Be Equal As Integers  ${resp.status_code}  200   
#    ${resp}=         PostCall    ${DBC_URL}/mr_clients    ${SUB3_DATA}
#    Should Be Equal As Integers  ${resp.status_code}  200   
#
#(DMAAP-297)
#    [Documentation]    Query for all topics and specific topic
#    Create Session     get          ${DBC_URL}
#    ${resp}=           Get Request   get    /topics  
#    Should Be Equal As Integers  ${resp.status_code}  200
#    ${resp}=           Get Request   get    /topics/${TOPIC_NS}.singleMRtopic3
#    Should Be Equal As Integers  ${resp.status_code}  200
#
#(DMAAP-301)
#    [Documentation]    Delete a subscriber
#    Create Session     get          ${DBC_URL}
#    ${resp}=           Get Request   get    /topics/${TOPIC_NS}.singleMRtopic3
#    Should Be Equal As Integers  ${resp.status_code}  200
#	${tmp}=            Get Json Value      ${resp.text}           /clients/1/mrClientId
#	${clientId}=       Remove String       ${tmp}         \"
#    ${resp}=           DelCall   ${DBC_URL}/mr_clients/${clientId}
#    Should Be Equal As Integers  ${resp.status_code}  204
#
#(DMAAP-302)
#    [Documentation]    Delete a publisher
#    Create Session     get          ${DBC_URL}
#    ${resp}=           Get Request   get    /topics/${TOPIC_NS}.singleMRtopic3
#    Should Be Equal As Integers  ${resp.status_code}  200
#	${tmp}=            Get Json Value      ${resp.text}           /clients/0/mrClientId
#	${clientId}=       Remove String       ${tmp}         \"
#    ${resp}=           DelCall   ${DBC_URL}/mr_clients/${clientId}
#    Should Be Equal As Integers  ${resp.status_code}  204


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

DelCall
    [Arguments]    ${url}           
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=       Evaluate    requests.delete('${url}', headers=${headers},verify=False)    requests
    [Return]       ${resp}
