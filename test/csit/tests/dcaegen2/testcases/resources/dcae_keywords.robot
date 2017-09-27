 *** Settings ***
Documentation     The main interface for interacting with DCAE. It handles low level stuff like managing the http request library and DCAE required fields
Library 	      RequestsLibrary
Library	          DcaeLibrary   
Library           OperatingSystem
Library           Collections
Variables         ../resources/DcaeVariables.py
Resource          ../resources/dcae_properties.robot
*** Variables ***
${DCAE_HEALTH_CHECK_BODY}    %{WORKSPACE}/test/csit/tests/dcae/testcases/assets/json_events/dcae_healthcheck.json
*** Keywords ***
Get DCAE Nodes
    [Documentation]    Get DCAE Nodes from Consul Catalog
    #Log    Creating session   ${GLOBAL_DCAE_CONSUL_URL}
    ${session}=    Create Session 	dcae 	${GLOBAL_DCAE_CONSUL_URL}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json  X-Consul-Token=abcd1234  X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${resp}= 	Get Request 	dcae 	/v1/catalog/nodes        headers=${headers}
    Log    Received response from dcae consul: ${resp.json()}
    Should Be Equal As Strings 	${resp.status_code} 	200
    ${NodeList}=   Get Json Value List   ${resp.text}   Node
    ${NodeListLength}=  Get Length  ${NodeList}  
    ${len}=  Get Length   ${NodeList}   
    Should Not Be Equal As Integers   ${len}   0
    [return]    ${NodeList}
DCAE Node Health Check
    [Documentation]    Perform DCAE Node Health Check
    [Arguments]    ${NodeName}
    ${session}=    Create Session 	dcae-${NodeName} 	${GLOBAL_DCAE_CONSUL_URL}
    ${uuid}=    Generate UUID
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json  X-Consul-Token=abcd1234  X-TransactionId=${GLOBAL_APPLICATION_ID}-${uuid}    X-FromAppId=${GLOBAL_APPLICATION_ID}
    ${hcpath}=   Catenate  SEPARATOR=    /v1/health/node/    ${NodeName}
    ${resp}= 	Get Request 	dcae-${NodeName} 	${hcpath}        headers=${headers}
    Log    Received response from dcae consul: ${resp.json()}
    Should Be Equal As Strings 	${resp.status_code} 	200
    ${StatusList}=  Get Json Value List   ${resp.text}    Status
    ${len}=  Get Length  ${StatusList}
    Should Not Be Equal As Integers   ${len}   0
    DCAE Check Health Status    ${NodeName}   ${StatusList[0]}    Serf Health Status
    #Run Keyword if  ${len} > 1  DCAE Check Health Status  ${NodeName}  ${StatusList[1]}  Serf Health Status
DCAE Check Health Status
    [Arguments]    ${NodeName}    ${ItemStatus}   ${CheckType}
    Should Be Equal As Strings    ${ItemStatus}    passing   
    Log   Node: ${NodeName} ${CheckType} check pass ok
VES Collector Suite Setup DMaaP
    [Documentation]   Start DMaaP Mockup Server
    ${ret}=  Setup DMaaP Server
    Should Be Equal As Strings     ${ret}    true
VES Collector Suite Shutdown DMaaP
    [Documentation]   Shutdown DMaaP Mockup Server
    ${ret}=  Shutdown DMaap
    Should Be Equal As Strings     ${ret}    true
Check DCAE Results
    [Documentation]    Parse DCAE JSON response and make sure all rows have healthTestStatus=GREEN
    [Arguments]    ${json}
    @{rows}=    Get From Dictionary    ${json['returns']}    rows
    @{headers}=    Get From Dictionary    ${json['returns']}    columns
    # Retrieve column names from headers
    ${columns}=    Create List
    :for    ${header}    in    @{headers}
    \    ${colName}=    Get From Dictionary    ${header}    colName
    \    Append To List    ${columns}    ${colName}
    # Process each row making sure status=GREEN
    :for    ${row}    in    @{rows}
    \    ${cells}=    Get From Dictionary    ${row}    cells
    \    ${dict}=    Make A Dictionary    ${cells}    ${columns}
    \    Dictionary Should Contain Item    ${dict}    healthTestStatus    GREEN
Make A Dictionary
    [Documentation]    Given a list of column names and a list of dictionaries, map columname=value
    [Arguments]     ${columns}    ${names}    ${valuename}=value
    ${dict}=    Create Dictionary
    ${collength}=    Get Length    ${columns}
    ${namelength}=    Get Length    ${names}
    :for    ${index}    in range    0   ${collength}
    \    ${name}=    Evaluate     ${names}[${index}]
    \    ${valued}=    Evaluate     ${columns}[${index}]
    \    ${value}=    Get From Dictionary    ${valued}    ${valueName}
    \    Set To Dictionary    ${dict}   ${name}    ${value}     
    [Return]     ${dict}
Get Event Data From File
    [Arguments]    ${jsonfile}
    ${data}=    OperatingSystem.Get File    ${jsonfile}
    #Should Not Be_Equal    ${data}    None
    [return]    ${data}
Json String To Dictionary
    [Arguments]  ${json_string}   
    ${json_dict}=  evaluate    json.loads('''${json_string}''')    json
    [return]   ${json_dict}
Dictionary To Json String
    [Arguments]  ${json_dict}
    ${json_string}=    evaluate    json.dumps(${json_dict})    json
    [return]    ${json_string}
Get DCAE Service Component Status
    [Documentation]   Get the status of a DCAE Service Component
    [Arguments]    ${url}    ${urlpath}     ${usr}    ${passwd}    
    ${auth}=  Create List  ${usr}  ${passwd}
    ${session}=    Create Session 	dcae-service-component 	${url}    auth=${auth}
    ${resp}= 	Get Request 	dcae-service-component 	${urlpath}
    [return]    ${resp}
Publish Event To VES Collector No Auth
    [Documentation]    Send an event to VES Collector
    [Arguments]     ${url}  ${evtpath}   ${httpheaders}    ${evtdata}
    Log    Creating session ${url}
    ${session}=    Create Session 	dcaegen2-d1 	${url}
    ${resp}= 	Post Request 	dcaegen2-d1 	${evtpath}     data=${evtdata}   headers=${httpheaders}
    #Log    Received response from dcae ${resp.json()}
    [return] 	${resp}
Publish Event To VES Collector
    [Documentation]    Send an event to VES Collector
    [Arguments]     ${url}  ${evtpath}   ${httpheaders}    ${evtdata}   ${user}  ${pd}
    ${auth}=  Create List  ${user}   ${pd}
    Log    Creating session ${url}
    ${session}=    Create Session 	dcaegen2-d1 	${url}    auth=${auth}   disable_warnings=1
    ${resp}= 	Post Request 	dcaegen2-d1 	${evtpath}     data=${evtdata}   headers=${httpheaders}
    #Log    Received response from dcae ${resp.json()}
    [return] 	${resp}
Publish Event To VES Collector With Put Method
    [Documentation]    Send an event to VES Collector
    [Arguments]     ${url}  ${evtpath}   ${httpheaders}    ${evtdata}   ${user}  ${pd}
    ${auth}=  Create List  ${user}   ${pd}
    Log    Creating session ${url}
    ${session}=    Create Session 	dcae-d1 	${url}    auth=${auth}
    ${resp}= 	Put Request 	dcae-d1 	${evtpath}     data=${evtdata}   headers=${httpheaders}
    #Log    Received response from dcae ${resp.json()}
    [return] 	${resp}
Publish Event To VES Collector With Put Method No Auth
    [Documentation]    Send an event to VES Collector
    [Arguments]     ${url}  ${evtpath}   ${httpheaders}    ${evtdata}
    Log    Creating session ${url}
    ${session}=    Create Session 	dcae-d1 	${url}
    ${resp}= 	Put Request 	dcae-d1 	${evtpath}     data=${evtdata}   headers=${httpheaders}
    #Log    Received response from dcae ${resp.json()}
    [return] 	${resp}
