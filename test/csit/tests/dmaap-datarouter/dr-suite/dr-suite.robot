*** Settings ***
Library           OperatingSystem
Library           RequestsLibrary
Library           requests
Library           Collections
Library           String

*** Variables ***
${TARGET_URL}                   https://${DR_PROV_IP}:8443
${TARGET_URL_FEED}              https://${DR_PROV_IP}:8443/feed/1
${TARGET_URL_SUBSCRIBE}         https://${DR_PROV_IP}:8443/subscribe/1
${TARGET_URL_SUBSCRIPTION}      https://${DR_PROV_IP}:8443/subs/1
${TARGET_URL_PUBLISH}           https://${DR_NODE_IP}:8443/publish/1/csit_test
${CREATE_FEED_DATA}             {"name": "CSIT_Test", "version": "m1.0", "description": "CSIT_Test", "business_description": "CSIT_Test", "suspend": false, "deleted": false, "changeowner": true, "authorization": {"classification": "unclassified", "endpoint_addrs": [],  "endpoint_ids": [{"password": "rs873m", "id": "rs873m"}]}}
${UPDATE_FEED_DATA}             {"name": "CSIT_Test", "version": "m1.0", "description": "UPDATED-CSIT_Test", "business_description": "CSIT_Test", "suspend": true, "deleted": false, "changeowner": true, "authorization": {"classification": "unclassified", "endpoint_addrs": [],  "endpoint_ids": [{"password": "rs873m", "id": "rs873m"}]}}
${SUBSCRIBE_DATA}               {"delivery":{ "url":"https://${DR_PROV_IP}:8080/",  "user":"rs873m", "password":"rs873m", "use100":true}, "metadataOnly":false, "suspend":false, "groupid":29, "subscriber":"sg481n"}
${UPDATE_SUBSCRIPTION_DATA}     {"delivery":{ "url":"https://${DR_PROV_IP}:8080/",  "user":"sg481n", "password":"sg481n", "use100":true}, "metadataOnly":false, "suspend":true, "groupid":29, "subscriber":"sg481n"}
${FEED_CONTENT_TYPE}            application/vnd.att-dr.feed
${SUBSCRIBE_CONTENT_TYPE}       application/vnd.att-dr.subscription
${PUBLISH_FEED_CONTENT_TYPE}    application/octet-stream

*** Test Cases ***
Run Feed Creation
    [Documentation]                 Feed Creation
    [Timeout]                       1 minute
    ${resp}=                        PostCall                         ${TARGET_URL}         ${CREATE_FEED_DATA}    ${FEED_CONTENT_TYPE}    rs873m
    log                             ${TARGET_URL}
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

Run Publish Feed
    [Documentation]                 Publish to Feed
    [Timeout]                       1 minute
    Sleep                           10s                              Behaviour was noticed where feed was not created in time for publish to be sent
    ${resp}=                        PutCall                          ${TARGET_URL_PUBLISH}    ${CREATE_FEED_DATA}      ${PUBLISH_FEED_CONTENT_TYPE}    rs873m
    log                             ${TARGET_URL_PUBLISH}
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              204
    log                             'JSON Response Code:'${resp}

Run Update Subscription
    [Documentation]                 Update Subscription to suspend and change delivery credentials
    [Timeout]                       1 minute
    ${resp}=                        PutCall                          ${TARGET_URL_SUBSCRIPTION}    ${UPDATE_SUBSCRIPTION_DATA}      ${SUBSCRIBE_CONTENT_TYPE}    sg481n
    log                             ${TARGET_URL_SUBSCRIPTION}
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              200
    log                             'JSON Response Code:'${resp}
    ${resp}=                        GetCall                          ${TARGET_URL_SUBSCRIPTION}    ${SUBSCRIBE_CONTENT_TYPE}    sg481n
    log                             ${resp.text}
    Should Contain                  ${resp.text}                     "password":"sg481n","user":"sg481n"
    log                             'JSON Response Code:'${resp}

Run Update Feed
    [Documentation]                 Update Feed description and suspend
    [Timeout]                       1 minute
    ${resp}=                        PutCall                          ${TARGET_URL_FEED}    ${UPDATE_FEED_DATA}      ${FEED_CONTENT_TYPE}    rs873m
    log                             ${TARGET_URL_FEED}
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              200
    log                             'JSON Response Code:'${resp}
    ${resp}=                        GetCall                          ${TARGET_URL_FEED}    ${FEED_CONTENT_TYPE}    rs873m
    log                             ${resp.text}
    Should Contain                  ${resp.text}                     "UPDATED-CSIT_Test"
    log                             'JSON Response Code:'${resp}

Run Delete Subscription
    [Documentation]                 Delete Subscription
    [Timeout]                       1 minute
    ${resp}=                        DeleteCall                       ${TARGET_URL_SUBSCRIPTION}    sg481n
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              204
    log                             'JSON Response Code:'${resp}

Run Delete Feed
    [Documentation]                 Delete Feed
    [Timeout]                       1 minute
    ${resp}=                        DeleteCall                       ${TARGET_URL_FEED}    rs873m
    log                             ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}              204
    log                             'JSON Response Code:'${resp}

*** Keywords ***
PostCall
    [Arguments]      ${url}              ${data}            ${content_type}        ${user}
    ${headers}=      Create Dictionary   X-ATT-DR-ON-BEHALF-OF=${user}    Content-Type=${content_type}
    ${resp}=         Evaluate            requests.post('${url}',data='${data}', headers=${headers},verify=False)    requests
    [Return]         ${resp}

PutCall
    [Arguments]      ${url}              ${data}            ${content_type}        ${user}
    ${headers}=      Create Dictionary   X-ATT-DR-ON-BEHALF-OF=${user}    Content-Type=${content_type}    Authorization=Basic cnM4NzNtOnJzODczbQ==
    ${resp}=         Evaluate            requests.put('${url}',data='${data}', headers=${headers},verify=False)    requests
    [Return]         ${resp}

GetCall
    [Arguments]      ${url}              ${content_type}        ${user}
    ${headers}=      Create Dictionary   X-ATT-DR-ON-BEHALF-OF=${user}    Content-Type=${content_type}
    ${resp}=         Evaluate            requests.get('${url}', headers=${headers},verify=False)    requests
    [Return]         ${resp}

DeleteCall
    [Arguments]      ${url}              ${user}
    ${headers}=      Create Dictionary   X-ATT-DR-ON-BEHALF-OF=${user}
    ${resp}=         Evaluate            requests.delete('${url}', headers=${headers},verify=False)    requests
    [Return]         ${resp}
