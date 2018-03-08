*** settings ***
Library           OperatingSystem
Library           Process
Library           String
Library           Collections
Library           RequestsLibrary
Library           json


*** Variables ***
${csarpath}   ${SCRIPTS}/../tests/vnfsdk-marketplace/provision/enterprise2DC.csar
${csarId}  0

*** Test Cases ***

Upload VNF Package to VNF Repository
    [Documentation]    Upload the VNF Package
    ${resp}=   Run    curl -s -X POST -H "Content-Type: multipart/form-data" -F "file=@${csarpath}" http://${REPO_IP}:8702/onapapi/vnfsdk-marketplace/v1/PackageResource/csars
    Should Contain    ${resp}    csarId
    ${csarjson}=    Evaluate    ${resp}
    ${csarId}=    Set Variable    ${csarjson["csarId"]}
    Set Global Variable    ${csarId}

Get VNF Package Information from Repository
    Create Session   refrepo  http://${REPO_IP}:8702
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Get Request    refrepo   /onapapi/vnfsdk-marketplace/v1/PackageResource/csars/${csarId}   headers=${headers}
    ${response_json}    json.loads    ${resp.content}
    ${downloadUri}=    Convert To String      ${response_json['downloadUri']}
    Should Contain    ${downloadUri}     ${csarId}
    Should Be Equal As Strings  ${resp.status_code}     200

Get List Of Requests 
    Create Session   refrepo  http://${REPO_IP}:8702
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Get Request    refrepo   /onapapi/vnfsdk-marketplace/v1/PackageResource/csars?name=enterprise2DC&version=1.0&type=SSAR&provider=huawei   headers=${headers}	
    Should Be Equal As Strings  ${resp.status_code}     200

Download VNF Package from Repository
    Create Session   refrepo  http://${REPO_IP}:8702
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Get Request    refrepo   /onapapi/vnfsdk-marketplace/v1/PackageResource/csars/${csarId}/files   headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${downloadUri}=    Convert To String    ${resp.content}
    ${downloadUri1}=    Run    curl http://${REPO_IP}:8702/onapapi/vnfsdk-marketplace/v1/PackageResource/csars/${csarId}/files
    ${string}=    Convert To String    ${downloadUri1}
    Should Contain    ${downloadUri1}    '  % Total    % Received % Xferd  Average
    Should Contain    ${string}    '  % Total    % Received % Xferd  Average

Delete VNF Package from Repository
    Create Session   refrepo  http://${REPO_IP}:8702
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Delete Request    refrepo    /onapapi/vnfsdk-marketplace/v1/PackageResource/csars/${csarId}   headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}     200

