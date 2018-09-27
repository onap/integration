 *** Settings ***
Documentation     The main interface for interacting with VES. It handles low level stuff like managing the http request library and VES required fields
Library 	      RequestsLibrary
Library	          ../resources/xNFLibrary.py
Library           OperatingSystem
Library           Collections
Library           requests
Library           Collections
Library           String

*** Variables ***

*** Keywords ***

Get Event Data From File
    [Arguments]    ${jsonfile}
    ${data}=    OperatingSystem.Get File    ${jsonfile}
    #Should Not Be_Equal    ${data}    None
    [return]    ${data}

Publish Event To VES Collector
    [Documentation]    Send an event to VES Collector
    [Arguments]     ${url}  ${evtpath}   ${httpheaders}    ${evtdata}
    Log    Creating session ${url}
    ${session}=    Create Session 	dcaegen2-d1 	${url}
    ${resp}= 	Post Request 	dcaegen2-d1 	${evtpath}     data=${evtdata}   headers=${httpheaders}
    #Log    Received response from dcae ${resp.json()}
    [return] 	${resp}
PostCall
    [Arguments]    ${url}    		${data}
    ${headers}=    Create Dictionary    Accept=application/json    Content-Type=application/json
    ${resp}=       Evaluate    requests.post('${url}',data='${data}', headers=${headers},verify=False)    requests
    [Return]       ${resp}

GetCall
    [Arguments]     ${url}
    ${resp}=    	Evaluate    requests.get('${url}')    requests
    [Return]    	${resp}
