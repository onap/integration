*** settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
@{return_ok_list}=   200  201  202
${queryswagger_url}    /api/nslcm/v1/swagger.json

*** Test Cases ***
NslcmSwaggerTest
    [Documentation]    query swagger info of nslcm
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${NSLCM_IP}:8403    headers=${headers}
    ${resp}=  Get Request    web_session    ${queryswagger_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${swagger_version}=    Convert To String      ${response_json['swagger']}
    Should Be Equal    ${swagger_version}    2.0

NslcmSwaggerByMSBTest
    [Documentation]    query swagger info of nslcm by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=  Get Request    web_session    ${queryswagger_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${swagger_version}=    Convert To String      ${response_json['swagger']}
    Should Be Equal    ${swagger_version}    2.0