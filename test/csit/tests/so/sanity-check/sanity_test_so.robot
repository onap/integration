*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${MESSAGE}    Hello, world!

*** Test Cases ***

Create ServiceInstance for invalid input
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createService.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /ecomp/mso/infra/serviceInstances/v2    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result 
	
Create ServiceInstance for invalid user
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createService.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQxOnBhc3N3b3JkMTI=    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /ecomp/mso/infra/serviceInstances/v2    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result	

Delete ServiceInstance for invalid input
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}deleteService.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    refrepo    /ecomp/mso/infra/serviceInstances/v2/ff305d54-75b4-431b-adb2-eb6b9e5ff000    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result    
	
Delete ServiceInstance for invalid user
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}deleteService.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQxOnBhc3N3b3JkMTI==    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    refrepo    /ecomp/mso/infra/serviceInstances/v2/ff305d54-75b4-431b-adb2-eb6b9e5ff000    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result
	
SO ServiceInstance health check
    Create Session   refrepo  http://${REPO_IP}:8080
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    refrepo    /ecomp/mso/infra/orchestrationRequests/v2/rq1234d1-5a33-55df-13ab-12abad84e333    headers=${headers}
    Should Not Contain     ${resp.content}      null

Create VnfInstance for invalid input
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createVnf.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /ecomp/mso/infra/serviceInstances/v2/ff305d54-75b4-431b-adb2-eb6b9e5ff000/vnfs    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result
	
Create VnfInstance for invalid credential
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createVnf.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQxOnBhc3N3b3JkMTI=    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /ecomp/mso/infra/serviceInstances/v2/ff305d54-75b4-431b-adb2-eb6b9e5ff000/vnfs    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result    
	
Delete VnfInstance for invalid input
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}deleteVnf.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    refrepo    /ecomp/mso/infra/serviceInstances/v2/ff305d54-75b4-431b-adb2-eb6b9e5ff000/vnfs/aca51b0a-710d-4155-bc7c-7cef19d9a94e    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result
	
Get Orchestration Requests
    Create Session   refrepo  http://${REPO_IP}:8080
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    refrepo    /ecomp/mso/infra/orchestrationRequests/v2    headers=${headers}
    Should Not Contain     ${resp.content}      null