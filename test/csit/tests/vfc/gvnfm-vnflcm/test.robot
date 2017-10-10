*** settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP

*** Variables ***
@{return_ok_list}=   200  201  202  204
${queryswagger_url}    /api/vnflcm/v1/swagger.json
${create_vnf_url}    /api/vnflcm/v1/vnf_instances
${delete_vnf_url}    /api/vnflcm/v1/vnf_instances

#json files
${create_vnf_json}    ${SCRIPTS}/../tests/vfc/gvnfm-vnflcm/jsoninput/create_vnf.json

#global variables
${vnfInstId}

*** Test Cases ***
VnflcmSwaggerTest
    [Documentation]    query swagger info vnflcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${VNFLCM_IP}:8801    headers=${headers}
    ${resp}=  Get Request    web_session    ${queryswagger_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${swagger_version}=    Convert To String      ${response_json['swagger']}
    Should Be Equal    ${swagger_version}    2.0

CreateVnfTest
    [Documentation]    Create Vnf function test
    ${json_value}=     json_from_file      ${create_vnf_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${VNFLCM_IP}:8801    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=    Post Request    web_session     ${create_vnf_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${vnfInstId}=    Convert To String      ${response_json['vnfInstanceId']}
    Set Global Variable     ${vnfInstId}

DeleteVnfTest
    [Documentation]    Delete Vnf function test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${VNFLCM_IP}:8801    headers=${headers}
    ${resp}=    Delete Request    web_session     ${delete_vnf_url}/${vnfInstId}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
