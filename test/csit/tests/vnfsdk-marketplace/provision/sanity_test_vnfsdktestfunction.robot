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
    ${resp}=   Run    curl -s -X POST -H "Content-Type: multipart/form-data" -F "file=@${csarpath}" http://${REPO_IP}:8702/openoapi/vnfsdk-marketplace/v1/PackageResource/csars
    Should Contain    ${resp}    csarId
    ${csarjson}=    Evaluate    ${resp}
    ${csarId}=    Set Variable    ${csarjson["csarId"]}
    Set Global Variable    ${csarId}

Get VNF Package Information from Repository
    Create Session   refrepo  http://${REPO_IP}:8702
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Get Request    refrepo   /openoapi/vnfsdk-marketplace/v1/PackageResource/csars/${csarId}   headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}     200

Download VNF Package from Repository
    Create Session   refrepo  http://${REPO_IP}:8702
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Get Request    refrepo   /openoapi/vnfsdk-marketplace/v1/PackageResource/csars/${csarId}/files   headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}     200

Delete VNF Package from Repository
    Create Session   refrepo  http://${REPO_IP}:8702
    &{headers}=  Create Dictionary      Content-Type=application/json
    ${resp}=    Delete Request    refrepo    /openoapi/vnfsdk-marketplace/v1/PackageResource/csars/${csarId}   headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}     200
