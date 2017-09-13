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
    Should Be Equal    2.0    2.0
