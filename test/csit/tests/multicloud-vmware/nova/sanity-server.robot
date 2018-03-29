*** settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP


*** Variables ***
@{return_ok_list}=   200  201  202
@{delete_ok_list}=   200  204
${get_token_url}    /api/multicloud-vio/v0/vmware_fake/identity/v3/auth/tokens

#json files
${auth_info_json}       ${SCRIPTS}/../tests/multicloud-vmware/provision/jsoninput/auth_info.json
${multicloud_create_server_json}    ${SCRIPTS}/../tests/multicloud-vmware/nova/jsoninput/multicloud_create_server.json

#global vars
${TOKEN}
${TENANTID}
${server1Id} 

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

CreateServerFuncTest
    [Documentation]    Sanity Test - Create Server
    ${json_value}=     json_from_file      ${multicloud_create_server_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json  X-Auth-Token=${TOKEN}
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    Set Request Body    ${json_string}
    #Log To Console     ${json_string}
    ${resp}=  Post Request    web_session    api/multicloud-vio/v0/vmware_fake/nova/${TENANTID}/servers    ${json_string}
    ${response_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${response_code}
    ${response_json}    json.loads    ${resp.content}
    #Log To Console        ${response_json}
    ${server1Id}=    Convert To String      ${response_json['server']['id']}
    Set Global Variable   ${server1Id}


GetServersFuncTest
    [Documentation]    Sanity Test - Get Servers
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json  X-Auth-Token=${TOKEN}
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=  Get Request    web_session    api/multicloud-vio/v0/vmware_fake/nova/${TENANTID}/servers
    ${response_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${response_code}
    ${response_json}    json.loads    ${resp.content}
    #Log To Console        ${response_json}
    #Log To Console        ${server1Id}

GetServerDetailFuncTest
    [Documentation]    Sanity Test - Get Server Detail
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json  X-Auth-Token=${TOKEN}
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=  Get Request    web_session    api/multicloud-vio/v0/vmware_fake/nova/${TENANTID}/servers/detail
    ${response_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${response_code}
    ${response_json}    json.loads    ${resp.content}
    #Log To Console        ${response_json}

GetServerFuncTest
    [Documentation]    Sanity Test - Get Server
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json  X-Auth-Token=${TOKEN}
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=  Get Request    web_session    api/multicloud-vio/v0/vmware_fake/nova/${TENANTID}/servers/${server1Id}
    ${response_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${response_code}
    ${response_json}    json.loads    ${resp.content}
    #Log To Console        ${response_json}

ServerActionFuncTest
    [Documentation]    Sanity Test - Server Action
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json  X-Auth-Token=${TOKEN}
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=  Get Request    web_session    api/multicloud-vio/v0/vmware_fake/nova/${TENANTID}/servers/${server1Id}/action
    ${response_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${response_code}
    ${response_json}    json.loads    ${resp.content}
    #Log To Console        ${response_json}
