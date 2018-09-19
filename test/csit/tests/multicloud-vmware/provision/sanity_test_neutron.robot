*** settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP


*** Variables ***
@{return_ok_list}=   200  201  202
@{delete_ok_list}=  200 204
${get_token_url}    	/api/multicloud-vio/v1/vmware_fake/identity/v3/auth/tokens
${get_networks_url} 	/api/multicloud-vio/v1/vmware_fake/neutron/networks

#json files
${auth_info_json}       ${SCRIPTS}/../tests/multicloud-vmware/provision/jsoninput/auth_info.json

#global vars
${TOKEN}
${NETWORKID}

*** Test Cases ***

GetAuthToken
    [Documentation]    Sanity test -  Get Auth Token
    ${json_value}=      json_from_file      ${auth_info_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=  POST Request    web_session    ${get_token_url}  ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${TOKEN}=    Convert To String      ${response_json['token']['value']}
    ${TENANTID}=    Convert To String   ${response_json['token']['project']['id']}
    Set Global Variable   ${TOKEN}


TestCaseListNetworks
    [Documentation]    Sanity test - List Networks
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json  X-Auth-Token=${TOKEN}
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=  Get Request    web_session   ${get_networks_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${NETWORKID}=    Convert To String   ${response_json['networks'][0]['id']}
    Set Global Variable   ${NETWORKID}




TestCaseShowNetwork
    [Documentation]    Sanity test - Show Network
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json  X-Auth-Token=${TOKEN}
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=  Get Request    web_session    ${get_networks_url}/${NETWORKID}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal     ${response_json['network']['status']}     ACTIVE
