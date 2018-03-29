*** settings ***
Resource    ../../common.robot
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     HttpLibrary.HTTP


*** Variables ***
@{return_ok_list}=   200  201  202


*** Test Cases ***

TestGetHost
    [Documentation]    Sanity Test - Get Image
    ${headers}    Create Dictionary    Content-Type=application/json    Accept=application/json
    Create Session    web_session    http://${VIO_IP}:9004    headers=${headers}
    ${resp}=  Get Request    web_session    api/multicloud-vio/v0/vmware_fake/1234/images/1
    ${response_code}=     Convert To String      ${resp.status_code}
    List Should Contain Value    ${return_ok_list}   ${response_code}
    ${response_json}    json.loads    ${resp.content}
    #Log To Console        ${response_json}
