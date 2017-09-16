*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       requests
Library       Collections

*** Variables ***
${COMPLEXKEYVALUE}  complex-integration-test3
${PSERVERKEYVALUE}  pserver-integration-test3
${COMPLEXURL}              https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/complexes/complex/${COMPLEXKEYVALUE}
${PSERVERURL}              https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/pservers/pserver/${PSERVERKEYVALUE}
${PSERVERRELATIONSHIPURL}  https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/pservers/pserver/${PSERVERKEYVALUE}/relationship-list/relationship
${COMPLEXDATA}  {"physical-location-id":"${COMPLEXKEYVALUE}","data-center-code":"example-data-center-code-val-77883","complex-name":"example-complex-name-val-12992","identity-url":"example-identity-url-val-74366","physical-location-type":"example-physical-location-type-val-32854","street1":"example-street1-val-26496","street2":"example-street2-val-6629","city":"example-city-val-30262","state":"example-state-val-9058","postal-code":"example-postal-code-val-44893","country":"example-country-val-98673","region":"example-region-val-10014","latitude":"example-latitude-val-47555","longitude":"example-longitude-val-76903","elevation":"example-elevation-val-63385","lata":"example-lata-val-90935"}
${PSERVERDATA}  {"hostname":"${PSERVERKEYVALUE}"}
${RELATIONSHIPDATA}  {"related-to":"complex","relationship-data":[{"relationship-key":"complex.physical-location-id","relationship-value":"${COMPLEXKEYVALUE}"}]}

*** Test Cases ***
Run AAI Put complex
    [Documentation]             Create an complex object
    ${resp}=                    PutWithCert              ${COMPLEXURL}              ${COMPLEXDATA}
    log                         ${COMPLEXURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201

Run AAI Get complex
    [Documentation]             Get the complex object just created
    ${resp}                     GetWithCert              ${COMPLEXURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
	
Run AAI Put pserver
    [Documentation]             Create pserver object
    ${resp}=                    PutWithCert              ${PSERVERURL}              ${PSERVERDATA}
    log                         ${PSERVERURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201

Run AAI Get pserver
    [Documentation]             Get the pserver
    ${resp}                     GetWithCert              ${PSERVERURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200

Run AAI Put pserver relationship with complex using relationship api
    [Documentation]             Create relationship between pserver and complex
    ${resp}=                    PutWithCert              ${PSERVERRELATIONSHIPURL}              ${RELATIONSHIPDATA}
    log                         ${PSERVERRELATIONSHIPURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      200	
	
Run AAI Get pserver to delete
    [Documentation]             Get pserver object to delete
    ${resp}                     GetWithCert              ${PSERVERURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete pserver
    [Documentation]             Delete the pserver
    ${resp}=                    DeleteWithCert           ${PSERVERURL}?resource-version=${resource_version}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      204
	
Run AAI Get complex to delete
    [Documentation]             Get complex object to delete
    ${resp}                     GetWithCert              ${COMPLEXURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete complex
    [Documentation]             Delete the complex
    ${resp}=                    DeleteWithCert           ${COMPLEXURL}?resource-version=${resource_version}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      204

*** Keywords ***
PutWithCert
    [Arguments]      ${url}      ${data}
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.put('${url}', data='${data}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}
	
PatchWithCert
    [Arguments]      ${url}      ${data}
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/merge-patch+json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.patch('${url}', data='${data}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}	

PostWithCert
    [Arguments]      ${url}      ${data}
    ${auth}=         Create List  AAI AAI
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.post('${url}', data='${data}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}

GetWithCert
    [Arguments]      ${url}
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.get('${url}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}

DeleteWithCert
    [Arguments]      ${url}
    ${auth}=         Create List  AAI AAI
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.delete('${url}', headers=${headers}, cert=${certinfo}, verify=False)    requests
    [return]         ${resp}