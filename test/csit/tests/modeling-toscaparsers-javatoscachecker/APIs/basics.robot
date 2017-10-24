*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json


*** Test Cases ***
Check service up
    CreateSession   checkerservice  http://localhost:8080
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    Get Request    checkerservice   /check_template/nosuchcatalog     headers=${headers}
    Should Be Equal As Strings  ${resp.status_code}     404

Check standalone template
    CreateSession   checkerservice  http://localhost:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}standalone.yaml
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    checkerservice   /check_template/     data=${data}     headers=${headers}
    Log    Response received from checker ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}     200

Check schema new namespace
    CreateSession   checkerservice  http://localhost:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}test_schema.yaml
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    checkerservice   /check_template/test/schema.yaml     data=${data}     headers=${headers}
    Log    Response received from checker ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}     200

Check template in namespace
    CreateSession   checkerservice  http://localhost:8080
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}test_template.yaml
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    Post Request    checkerservice   /check_template/test/     data=${data}     headers=${headers}
    Log    Response received from checker ${resp.text}
    Should Be Equal As Strings      ${resp.status_code}     200

Check delete existing namespace
    CreateSession   checkerservice  http://localhost:8080
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    Delete Request    checkerservice   /check_template/test/     headers=${headers}
    Log    Response received from checker ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}     200
