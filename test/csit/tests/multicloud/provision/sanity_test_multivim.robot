*** settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
@{return_ok_list}=   200  201  202
${queryswagger_broker_url}    /api/multicloud/v0/swagger.json
${check_capacity_broker_url}    /api/multicloud/v0/check_vim_capacity


*** Test Cases ***
BrokerSwaggerTest
    [Documentation]    query swagger info rest test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${BROKER_IP}:9001    headers=${headers}
    ${resp}=  Get Request    web_session    ${queryswagger_broker_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${swagger_version}=    Convert To String      ${response_json['swagger']}
    Should Be Equal    ${swagger_version}    2.0

BrokerCapacityTest
    [Documentation]    Check VIMs capacity
    ${data}=         Get Binary File     ${CURDIR}${/}data${/}capacity.json
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${BROKER_IP}:9001    headers=${headers}
    ${resp}=  Post Request    web_session    ${check_capacity_broker_url}  ${data}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
