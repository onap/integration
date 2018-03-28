*** settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     simplejson
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP

*** Variables ***
@{return_ok_list}=   200  201  202
${queryswagger_url}    /api/multivimproxy/v1/swagger.json

*** Test Cases ***
SwaggerFuncTest
    [Documentation]    query swagger info rest test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${RESMGR_IP}:8486    headers=${headers}
    ${resp}=  Get Request    web_session    ${queryswagger_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${swagger_version}=    Convert To String      ${response_json['swagger']}
    Should Be Equal    ${swagger_version}    2.0