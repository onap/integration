*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       requests
Library       Collections

*** Variables ***
${COMPLEXKEYVALUE1}  complex-integration-test3-1
${COMPLEXKEYVALUE2}  complex-integration-test3-2
${COMPLEXURL1}       https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/complexes/complex/${COMPLEXKEYVALUE1}
${COMPLEXURL2}       https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/complexes/complex/${COMPLEXKEYVALUE2}
${ALLCOMPLEXURL}     https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/complexes
${COMPLEXDATA1}  {"physical-location-id":"${COMPLEXKEYVALUE1}","data-center-code":"example-data-center-code-val-77883","complex-name":"example-complex-name-val-12992","identity-url":"example-identity-url-val-74366","physical-location-type":"example-physical-location-type-val-32854","street1":"example-street1-val-26496","street2":"example-street2-val-6629","city":"example-city-val-30262","state":"example-state-val-9058","postal-code":"example-postal-code-val-44893","country":"example-country-val-98673","region":"example-region-val-10014","latitude":"example-latitude-val-47555","longitude":"example-longitude-val-76903","elevation":"example-elevation-val-63385","lata":"example-lata-val-90935"}
${COMPLEXDATA2}  {"physical-location-id":"${COMPLEXKEYVALUE2}","data-center-code":"example-data-center-code-val-7783","complex-name":"example-complex-name-val-1292","identity-url":"example-identity-url-val-7466","physical-location-type":"example-physical-location-type-val-3854","street1":"example-street1-val-2496","street2":"example-street2-val-6629","city":"example-city-val-3062","state":"example-state-val-9058","postal-code":"example-postal-code-val-4493","country":"example-country-val-9873","region":"example-region-val-1004","latitude":"example-latitude-val-4555","longitude":"example-longitude-val-7603","elevation":"example-elevation-val-6335","lata":"example-lata-val-9035"}

*** Test Cases ***

Run AAI Put complex 1
    [Documentation]             Create an complex 1 object
    ${resp}=                    PutWithCert              ${COMPLEXURL1}              ${COMPLEXDATA1}
    log                         ${COMPLEXURL1}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201
	
Run AAI Put complex 2
    [Documentation]             Create an complex 2 object
    ${resp}=                    PutWithCert              ${COMPLEXURL2}              ${COMPLEXDATA2}
    log                         ${COMPLEXURL2}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201	

Run AAI Get all complex
    [Documentation]             Get the complex object just created
    ${resp}                     GetWithCert              ${ALLCOMPLEXURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200	
	
Run AAI Get complex 1 to delete
    [Documentation]             Get the complex 1 object to delete
    ${resp}                     GetWithCert              ${COMPLEXURL1}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete complex 1
    [Documentation]             Delete the complex just created
    ${resp}=                    DeleteWithCert           ${COMPLEXURL1}?resource-version=${resource_version}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      204
	
Run AAI Get complex 2 to delete
    [Documentation]             Get the complex 2 object to delete
    ${resp}                     GetWithCert              ${COMPLEXURL2}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete complex 2
    [Documentation]             Delete the complex just created
    ${resp}=                    DeleteWithCert           ${COMPLEXURL2}?resource-version=${resource_version}
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