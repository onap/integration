*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${MESSAGE}    ('Connection aborted.', error(104, 'Connection reset by peer'))


*** Test Cases ***

Create ServiceInstance for invalid input
    Create Session   refrepo  http://127.0.0.1:8080
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /ecomp/mso/infra/serviceInstance/v2    headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}     400

Delete ServiceInstance for invalid input
    Create Session   refrepo  http://127.0.0.1:8080
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    refrepo    /ecomp/mso/infra/serviceInstance/v2/ff305d54-75b4-431b-adb2-eb6b9e5ff000    headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}     400

SO ServiceInstance health check
    Create Session   refrepo  http://127.0.0.1:8080
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    refrepo    /ecomp/mso/infra/orchestrationRequest/v2/rq1234d1-5a33-55df-13ab-12abad84e333    headers=${headers}
    Should Not Contain Match     ${resp}      *success*