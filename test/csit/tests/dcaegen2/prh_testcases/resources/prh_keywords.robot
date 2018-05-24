*** Settings ***
Documentation     The main interface for interacting with PRH. It handles low level stuff like managing the http request library
Library           PrhLibrary.py
Library           RequestsLibrary

*** Variables ***

*** Keywords ***
PRH Suite Setup
    [Documentation]    Start DMaaP and AAI Mockup Server
    ${ret}=    Setup DMaaP Server
    Should Be Equal As Strings    ${ret}    true
    ${ret}=    Setup AAI Server
    Should Be Equal As Strings    ${ret}    true

PRH Suite Shutdown
    [Documentation]    Shutdown DMaaP and AAI Mockup Server
    ${ret}=    Shutdown DMaap Server
    Should Be Equal As Strings    ${ret}    true
    ${ret}=    Shutdown AAI Server
    Should Be Equal As Strings    ${ret}    true

Get event from DMaaP
    [Arguments]    ${ip}    ${endpoint}
    [Documentation]    Get an event from DMaaP
    ${url}=    Catenate    SEPARATOR=    ${ip}    ${endpoint}
    Log    Creating session ${url}
    Create Session    prh-d1    ${url}
    ${resp}=    Get Request    prh-d1    ${url}
    Log    Received response from dcae ${resp.json()}
    [Return]    ${resp}

Send patch from AAI
    [Arguments]    ${ip}    ${endpoint}
    [Documentation]    Get patch from AAI
    ${url}=    Catenate    SEPARATOR=    ${ip}    ${endpoint}
    Log    Creating session ${url}
    Create Session    prh-d1    ${url}
    ${resp}=    Patch Request    prh-d1    ${url}
    Log    ${resp}
    [Return]    ${resp}

Get json from AAI
    [Arguments]    ${ip}    ${endpoint}
    [Documentation]    Get json from AAI
    ${url}=    Catenate    SEPARATOR=    ${ip}    ${endpoint}
    Log    Creating session ${url}
    Create Session    prh-d1    ${url}
    ${resp}=    Get Request    prh-d1    ${url}
    Log    Received response from dcae ${resp.json()}
    [Return]    ${resp}

Post json to DMaaP
    [Arguments]    ${ip}    ${endpoint}    ${PNF_READY}
    [Documentation]    Get json from AAI
    ${url}=    Catenate    SEPARATOR=    ${ip}    ${endpoint}
    Log    Creating session ${url}
    Create Session    prh-d1    ${url}
    ${resp}=    Post Request    prh-d1    ${url}    data=${PNF_READY}
    Log    ${resp}
    [Return]    ${resp}
