*** settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     simplejson
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP

*** Variables ***
@{return_ok_list}=   200  201  202  204
${queryswagger_url}    /api/huaweivnfmdriver/v1/swagger.json
${createauthtoken_url}    /rest/plat/smapp/v1/oauth/token

#json files
${hwvnfm_createtoken_json}    ${SCRIPTS}/../tests/vfc/nfvo-driver-svnfm/jsoninput/hwvnfm_createtoken.json

*** Test Cases ***
SwaggerFuncTest
    [Documentation]    query swagger info rest test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${SERVICE_IP}:8482    headers=${headers}
    ${resp}=  Get Request    web_session    ${queryswagger_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${swagger_version}=    Convert To String      ${response_json['swagger']}
    Should Be Equal    ${swagger_version}    2.0

AuthTokenFuncTest
    [Documentation]    create auth token rest test
    ${json_value}=     json_from_file      ${hwvnfm_createtoken_json}
    ${json_string}=     string_from_json   ${json_value}
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${SERVICE_IP}:8482    headers=${headers}
    Set Request Body    ${json_string}
    ${resp}=  Put Request    web_session    ${createauthtoken_url}    ${json_string}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}