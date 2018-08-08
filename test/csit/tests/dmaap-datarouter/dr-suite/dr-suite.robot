*** Settings ***
Library           OperatingSystem
Library           RequestsLibrary
Library           requests
Library           Collections
Library           String

*** Variables ***
${TARGET_URL_FEED}              https://${DR_PROV_IP}:8443
${TARGET_URL_SUBSCRIBE}         https://${DR_PROV_IP}:8443/subscribe/1
${CREATE_FEED_DATA}             {"name": "CSIT_Test", "version": "m1.0", "description": "CSIT_Test", "business_description": "CSIT_Test", "suspend": false, "deleted": false, "changeowner": true, "authorization": {"classification": "unclassified", "endpoint_addrs": ["${DR_PROV_IP}"],  "endpoint_ids": [{"password": "rs873m", "id": "rs873m"}]}}
${SUBSCRIBE_DATA}               {"delivery":{ "url":"https://${DR_PROV_IP}:8080/",  "user":"rs873m", "password":"rs873m", "use100":true}, "metadataOnly":false, "suspend":false, "groupid":29, "subscriber":"sg481n"}
${FEED_CONTENT_TYPE}            application/vnd.att-dr.feed
${SUBSCRIBE_CONTENT_TYPE}       application/vnd.att-dr.subscription

*** Test Cases ***
Run Feed Creation
    [Documentation]                 Feed Creation
    [Timeout]                       1 minute
    ${resp}=                        PostCall                         ${TARGET_URL_FEED}         ${CREATE_FEED_DATA}    ${FEED_CONTENT_TYPE}    rs873m
    log                             ${TARGET_URL_FEED}
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              201
    log                             'JSON Response Code:'${resp}

Run Subscribe to Feed
    [Documentation]                 Subscribe to Feed
    [Timeout]                       1 minute
    ${resp}=                        PostCall                         ${TARGET_URL_SUBSCRIBE}    ${SUBSCRIBE_DATA}      ${SUBSCRIBE_CONTENT_TYPE}    sg481n
    log                             ${TARGET_URL_SUBSCRIBE}
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              201
    log                             'JSON Response Code:'${resp}

*** Keywords ***
PostCall
    [Arguments]      ${url}              ${data}            ${content_type}        ${user}
    ${headers}=      Create Dictionary   X-ATT-DR-ON-BEHALF-OF=${user}    Content-Type=${content_type}
    ${resp}=         Evaluate            requests.post('${url}',data='${data}', headers=${headers},verify=False)    requests
    [Return]         ${resp}
