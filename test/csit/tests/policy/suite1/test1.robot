*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary

*** Variables ***
${MESSAGE}    Hello, world!

*** Test Cases ***
String Equality Test
    Should Be Equal    ${MESSAGE}    Hello, world!

Dir Test
    [Documentation]    Check if /tmp exists
    Log                ${MESSAGE}
    CheckDir           /tmp

Url Test
    [Documentation]    Check if google.com can be reached
    CheckUrl           http://www.google.com

*** Keywords ***
CheckDir
    [Arguments]                 ${path}
    Directory Should Exist      ${path}

CheckUrl
    [Arguments]                  ${url}
    Create Session               session              ${url}
    ${resp}=                     Get Request          session                  /
    Should Be Equal As Integers  ${resp.status_code}  200
