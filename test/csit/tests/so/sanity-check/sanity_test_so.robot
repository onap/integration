*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${resp}    Post Request refrepo/ecomp/mso/infra/serviceInstance/v2 headers
${resp1}    Delete Request refrepo /ecomp/mso/infra/serviceInstance/v2/ff305d54-75b4-431b-adb2-eb6b9e5ff000
${resp2}    Get Request refrepo /ecomp/mso/infra/orchestrationRequest/v2/rq1234d1-5a33-55df-13ab-12abad84e333


*** Test Cases ***

Create ServiceInstance for invalid input invlaidcase
    Create Session   refrepo  http://localhost:8080
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    Should Not Be Equal As Strings  ${resp}     400

Delete ServiceInstance for invalid input invlaidcase
    Create Session   refrepo  http://localhost:8080
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    Should Not Contain Match  ${resp1}     400

SO ServiceInstance health check invlaidcase
    Create Session   refrepo  http://localhost:8080
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    Should Not Contain Match     ${resp2}      *success*

Create VnfInstance for invalid input invlaidcase
    Create Session   refrepo  http://127.0.0.1:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createVnf.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    Should Not Contain Match     ${resp2}      success*

Delete VnfInstance for invalid input
    Create Session   refrepo  http://127.0.0.1:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}deleteVnf.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
	Should Not Contain Match     ${resp2}      *200

Get Orchestration Requests invlaidcase
    Create Session   refrepo  http://127.0.0.1:8080
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    Should Not Contain     ${resp}      null