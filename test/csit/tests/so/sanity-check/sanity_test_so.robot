*** settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP

*** Variables ***
@{return_ok_list}=   200  201  202
${queryservice_url}       /api/so/v1/services/5212b49f-fe70-414f-9519-88bec35b3190
${service_id}
${operation_id}
*** Test Cases ***
soQueryServiceFuncTest
    [Documentation]    query single service rest test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IP}    headers=${headers}
    ${resp}=  Get Request    web_session    ${queryservice_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${responese_code}
    ${response_json}    json.loads    ${resp.content}
    ${serviceName}=    Convert To String      ${response_json['serviceName']}
    Should Be Equal    ${serviceName}    test_so

