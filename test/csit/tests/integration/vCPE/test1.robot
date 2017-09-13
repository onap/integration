*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary

*** Test Cases ***
SO ServiceInstance health check
    Create Session   refrepo  http://${SO_IP}:8080
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    refrepo    /ecomp/mso/infra/orchestrationRequests/v2/rq1234d1-5a33-55df-13ab-12abad84e333    headers=${headers}
    Should Not Contain     ${resp.content}      null
