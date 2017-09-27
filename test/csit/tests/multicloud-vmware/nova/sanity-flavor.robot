*** settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP


*** Variables ***
@{return_ok_list}=   200  201  202
${get_token_url}    /api/multicloud-vio/v0/vmware_fake/identity/v3/auth/tokens

#json files
${auth_info_json}       ${SCRIPTS}/../tests/multicloud-vmware/provision/jsoninput/auth_info.json

#global vars
${TOKEN}
${TENANTID}
${flavor1Id} 

*** Test Cases ***

GetAuthToken
    [Documentation]    Sanity test -  Get Auth Token
    ${json_value}=      json_from_file      ${auth_info_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${VIO_IP}:9004     headers=${headers}
    ${resp}=  POST Request    web_session    ${get_token_url}  ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${TOKEN}=    Convert To String      ${response_json['token']['value']}
    ${TENANTID}=    Convert To String   ${response_json['token']['project']['id']}
    Set Global Variable   ${TOKEN}
    Set Global Variable   ${TENANTID}


ListFlavorsFuncTest
    [Documentation]    get a list of flavors info rest test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json     X-Auth-Token=${TOKEN}
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=    GET Request    web_session     api/multicloud-vio/v0/vmware_fake/nova/${TENANTID}/flavors
    ${response_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${response_code}
    ${response_json}    json.loads    ${resp.content}
    #Log To Console        ${response_json}
    ${flavor1Id}=    Convert To String      ${response_json['flavors'][0]['id']}
    Set Global Variable   ${flavor1Id}
    #Log To Console        ${flavor1Id}

GetFlavorFuncTest
    [Documentation]    get the specific flavor info rest test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json     X-Auth-Token=${TOKEN}
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=    GET Request    web_session     api/multicloud-vio/v0/vmware_fake/nova/${TENANTID}/flavors/${flavor1Id}
    ${response_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${response_code}
    ${response_json}    json.loads    ${resp.content}
    #Log To Console        ${response_json}

