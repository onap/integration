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
    ${resp}=    Post Request    refrepo    /onap/so/infra/serviceInstances/v5    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result 
	
Create ServiceInstance for invalid user
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createService.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQxOnBhc3N3b3JkMTI=    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/serviceInstances/v5    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result	

Delete ServiceInstance for invalid input
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}deleteService.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result    
	
Delete ServiceInstance for invalid user
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}deleteService.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQxOnBhc3N3b3JkMTI==    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Activate ServiceInstance
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}activateService.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/activate    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Deactivate ServiceInstance
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}deactivateService.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/deactivate    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Create Volume Group instance
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createVG.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/vnfs/aca51b0a-710d-4155-bc7c-7cef19d9a94e/volumeGroups    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Delete Volume Group instance
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}deleteVG.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/vnfs/aca51b0a-710d-4155-bc7c-7cef19d9a94e/volumeGroups/ff305d54-75b4-ff1b-cdb2-eb6b9e5460ff    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result
	
Create VF Module instance
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createVF.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/vnfs/aca51b0a-710d-4155-bc7c-7cef19d9a94e/vfModules    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Update VF Module instance
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}updateVF.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/vnfs/aca51b0a-710d-4155-bc7c-7cef19d9a94e/vfModules/ff305d54-75b4-ff1b-bdb2-eb6b9e5460ff    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Delete VF Module instance
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}deleteVF.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/vnfs/aca51b0a-710d-4155-bc7c-7cef19d9a94e/vfModules/ff305d54-75b4-ff1b-bdb2-eb6b9e5460ff    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Replace VF Module instance
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}replaceVF.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/vnfs/aca51b0a-710d-4155-bc7c-7cef19d9a94e/vfModules/ff305d54-75b4-ff1b-bdb2-eb6b9e5460ff/replace    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Create Network instance
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createNetwork.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/networks    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Update Network instance
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}updateNetwork.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Put Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/networks/2b125640-bd1a-4ef0-9ca0-ea76e2a22801    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Delete Network instance
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}deleteNetwork.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/networks/2b125640-bd1a-4ef0-9ca0-ea76e2a22801    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

SO ServiceInstance health check
    Create Session   refrepo  http://${REPO_IP}:8080
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    refrepo    /onap/so/infra/orchestrationRequests/v5/rq1234d1-5a33-55df-13ab-12abad84e333    headers=${headers}
    Should Not Contain     ${resp.content}      null

Create VnfInstance for invalid input
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createVnf.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/vnfs    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Update VnfInstance for invalid input
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}updateVnf.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/vnfs/aca51b0a-710d-4155-bc7c-7cef19d9a94e    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result
	
Create VnfInstance for invalid credential
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createVnf.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQxOnBhc3N3b3JkMTI=    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/vnfs    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result    
	
Delete VnfInstance for invalid input
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}deleteVnf.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/vnfs/aca51b0a-710d-4155-bc7c-7cef19d9a94e    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Replace VnfInstance
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}replaceVnf.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQxOnBhc3N3b3JkMTI=    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/serviceInstances/v5/ff305d54-75b4-431b-adb2-eb6b9e5ff000/vnfs/aca51b0a-710d-4155-bc7c-c7cef19d94e/replace    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result
	
Get Orchestration Requests
    Create Session   refrepo  http://${REPO_IP}:8080
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    refrepo    /onap/so/infra/orchestrationRequests/v5    headers=${headers}
    Should Not Contain     ${resp.content}      null

Get Orchestration Requests Filter criteria
    Create Session   refrepo  http://${REPO_IP}:8080
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    refrepo    /onap/so/infra/orchestrationRequests/v5?filter=serviceInstanceId:EQUALS:bc305d54-75b4-431b-adb2-eb6b9e546014    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Create E2EService
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createE2eservice.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/e2eServiceInstances/v3    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Create E2EService with invalid credential
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createE2eservice.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQxOnBhc3N3b3JkMTI=    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/e2eServiceInstances/v3    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Create E2EService with invalid Input data
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}createE2eserviceInvalid.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQxOnBhc3N3b3JkMTI=    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    refrepo    /onap/so/infra/e2eServiceInstances/v3    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Delete E2EService
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}deleteE2eservice.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    refrepo    /onap/so/infra/e2eServiceInstances/v3/ff305d54-75b4-431b-adb2-eb6b9e5ff000    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Delete E2EService with invalid credential
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}deleteE2eservice.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQxOnBhc3N3b3JkMTI=    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    refrepo    /onap/so/infra/e2eServiceInstances/v3/ff305d54-75b4-431b-adb2-eb6b9e5ff000    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result

Delete E2EService with invalid input data
    Create Session   refrepo  http://${REPO_IP}:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}deleteE2eserviceInvalid.json
    &{headers}=  Create Dictionary    Authorization=Basic SW5mcmFQb3J0YWxDbGllbnQ6cGFzc3dvcmQxJA==    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    refrepo    /onap/so/infra/e2eServiceInstances/v3/ff305d54-75b4-431b-adb2-eb6b9e5ff000    data=${data}    headers=${headers}
    Run Keyword If  '${resp.status_code}' == '400' or '${resp.status_code}' == '404' or '${resp.status_code}' == '405'  log to console  \nexecuted with expected result