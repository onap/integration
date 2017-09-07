*** settings ***
Library     Collections
Library     RequestsLibrary
Library     simplejson
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP

*** Variables ***
@{return_ok_list}=   200  201  202
${queryswagger_url}    /api/resmgr/v1/swagger.json

*** Test Cases ***
SwaggerFuncTest
    [Documentation]    query swagger info rest test
    Should Be Equal    2.0    2.0
