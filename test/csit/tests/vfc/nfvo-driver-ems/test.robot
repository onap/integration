*** settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
@{return_ok_list}=   200  201  202
${queryswagger_url}    /api/emsdriver/v1/swagger

*** Test Cases ***
EMSDriverSwaggerTest
    [Documentation]    query swagger info of emsdriver
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=  Get Request    web_session    ${queryswagger_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    Should Be Equal    2.0    2.0

EMSDriverSwaggerByMSBTest
    [Documentation]    query swagger info of emsdriver by MSB
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${MSB_IAG_IP}:80    headers=${headers}
    ${resp}=  Get Request    web_session    ${queryswagger_url}
    ${responese_code}=     Convert To String      ${resp.status_code}
    Should Be Equal    2.0    2.0	

		