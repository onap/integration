*** settings ***
Library           OperatingSystem
Library           Process
Library           String
Library           Collections
Library           RequestsLibrary
Library           json


*** Variables ***
${valid_heat_zip}   ${SCRIPTS}/../tests/vnfsdk-ice/ice-server/heat_template_ok.zip
${empty_heat_zip}   ${SCRIPTS}/../tests/vnfsdk-ice/ice-server/heat_template_empty.zip
${ice_uri}           /onapapi/ice/v1/

*** Test Cases ***

ICE health Check
    [Documentation]  Validate that ICE is up
    Create Session   ice_session  http://${ICE_IP}:5000
    &{headers}=  Create Dictionary      Content-Type=application/json

    ${resp}=    Get Request    ice_session   ${ice_uri}   headers=${headers}

    Should Be Equal As Strings  ${resp.status_code}     200

Check status code for valid HEAT based VNF package
    [Documentation]    Post a valid VNF package and expect 200 Response
    ${fileData}=  Get Binary File  ${valid_heat_zip}
    ${fileDir}  ${fileName}=  Split Path  ${valid_heat_zip}
    ${partData}=  Create List  ${fileName}  ${fileData}  application/octet-stream
    &{fileParts}=  Create Dictionary
    Set To Dictionary  ${fileParts}  file=${partData}

    ${resp}=  Post Request  ice_session  ${ice_uri}  files=${fileParts}

    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings  ${resp.status_code}     200
    ${json} =  Set Variable  ${resp.json()}
    ${message} =  Get From Dictionary  ${json}  message
    Should Be Equal  ${message}  OK

Check status code for empty VNF package
    [Documentation]    Post an empty VNF package and expect 422 Response
    ${fileData}=  Get Binary File  ${empty_heat_zip}
    ${fileDir}  ${fileName}=  Split Path  ${empty_heat_zip}
    ${partData}=  Create List  ${fileName}  ${fileData}  application/octet-stream
    &{fileParts}=  Create Dictionary
    Set To Dictionary  ${fileParts}  file=${partData}

    ${resp}=  Post Request  ice_session  ${ice_uri}  files=${fileParts}

    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings  ${resp.status_code}     422
    ${json} =  Set Variable  ${resp.json()}
    ${message} =  Get From Dictionary  ${json}  message
    Should Be Equal  ${message}  Tests failed

Check status code for invalid request
    [Documentation]    Post an invalid request and expect 400 Response
    ${fileData}=  Get Binary File  ${empty_heat_zip}
    ${fileDir}  ${fileName}=  Split Path  ${empty_heat_zip}
    ${partData}=  Create List  ${fileName}  ${fileData}  application/octet-stream
    &{fileParts}=  Create Dictionary
    Set To Dictionary  ${fileParts}  foo=${partData}

    ${resp}=  Post Request  ice_session  ${ice_uri}  files=${fileParts}

    Log    Receive HTTP Status code ${resp.status_code}
    Should Be Equal As Strings  ${resp.status_code}     400
