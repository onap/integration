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
    [Documentation]    query nslcm swagger info rest test
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IP}    headers=${headers}
    ${resp}=  Get Request    web_session    ${queryswagger_url}
    Should Be Equal    2.0    2.0
