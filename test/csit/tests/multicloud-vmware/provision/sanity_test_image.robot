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
${get_token_url}         /api/multicloud-vio/v0/vmware_fake/identity/v3/auth/tokens
${get_image_url}         /api/multicloud-vio/v0/vmware_fake/glance/v2/images
${get_image_schema_url}  /api/multicloud-vio/v0/vmware_fake/glance/v2/schemas/image
${image_service}         /api/multicloud-vio/v0/vmware_fake/glance/v2/image/file



#json files
${auth_info_json}        ${SCRIPTS}/../tests/multicloud-vmware/provision/jsoninput/auth_info.json
${image_file}            ${SCRIPTS}/../tests/multicloud-vmware/provision/jsoninput/image_file.json

#global vars
${TOKEN}
${IMAGEID}

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





TestCaseShowImageSchema
    [Documentation]    Sanity test - Show Image Schema
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json  X-Auth-Token=${TOKEN}
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=  Get Request    web_session    ${get_image_schema_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}




TestCaseListImages
    [Documentation]    Sanity test - List Images
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json  X-Auth-Token=${TOKEN}
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=  Get Request    web_session    ${get_image_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${IMAGEID}=    Convert To String  ${response_json['images'][0]['id']}
    Set Global Variable   ${IMAGEID}




TestCaseShowImage
    [Documentation]    Sanity test - Show Image
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json  X-Auth-Token=${TOKEN}
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=  Get Request    web_session    ${get_image_url}/${IMAGEID}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal     ${response_json['status']}    active




TestCaseUploadImage
    [Documentation]    Sanity test - Upload Image
    ${json_value}=      json_from_file      ${image_file}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json  X-Auth-Token=${TOKEN}
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=  POST Request    web_session    ${image_service}   ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${IMAGEID}=    Convert To String  ${response_json['id']}
    Set Global Variable   ${IMAGEID}




TestCaseDownloadImage
    [Documentation]    Sanity test - Download Image
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json  X-Auth-Token=${TOKEN}
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=  Get Request    web_session    ${image_service}/${IMAGEID}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    Should Be Equal     ${response_json['status']}    active