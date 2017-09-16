*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       requests
Library       Collections

*** Variables ***
${COMPLEXKEYVALUE}     complex-integration-test2
${L3NETWORKKEYVALUE}   l3-network-integration-test2
${COMPLEXURL}    https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/complexes/complex/${COMPLEXKEYVALUE}
${L3NETWORKURL}  https://${HOST_IP}:8443/aai/v11/network/l3-networks/l3-network/${L3NETWORKKEYVALUE}
${COMPLEXDATA}  {"physical-location-id":"${COMPLEXKEYVALUE}","data-center-code":"example-data-center-code-val-77883","complex-name":"example-complex-name-val-12992","identity-url":"example-identity-url-val-74366","physical-location-type":"example-physical-location-type-val-32854","street1":"example-street1-val-26496","street2":"example-street2-val-6629","city":"example-city-val-30262","state":"example-state-val-9058","postal-code":"example-postal-code-val-44893","country":"example-country-val-98673","region":"example-region-val-10014","latitude":"example-latitude-val-47555","longitude":"example-longitude-val-76903","elevation":"example-elevation-val-63385","lata":"example-lata-val-90935"}
${L3NETWORKDATA}  {"network-id":"${L3NETWORKKEYVALUE}","network-name":"example-network-name-val-5468","network-type":"example-network-type-val-5468","network-role":"example-network-role-val-5468","network-technology":"example-network-technology-val-5468","neutron-network-id":"example-neutron-network-id-val-5468","is-bound-to-vpn":"true","service-id":"example-service-id-val-5468","orchestration-status":"example-orchestration-status-val-5468","heat-stack-id":"example-heat-stack-id-val-5468","mso-catalog-key":"example-mso-catalog-key-val-5468","relationship-list":{"relationship":[{"related-to":"complex","relationship-data":[{"relationship-key":"complex.physical-location-id","relationship-value":"${COMPLEXKEYVALUE}"}]}]}}

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
	
Run AAI Put l3-network relationship with complex
    [Documentation]             Create l3-network relationship with complex
    ${resp}=                    PutWithCert              ${L3NETWORKURL}              ${L3NETWORKDATA}
    log                         ${L3NETWORKURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201

Run AAI Get l3-network
    [Documentation]             Get the l3-network object just created with relationship with complex
    ${resp}                     GetWithCert              ${L3NETWORKURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200	
	
Run AAI Get l3-network to delete
    [Documentation]             Get l3-network object to delete
    ${resp}                     GetWithCert              ${L3NETWORKURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete l3-network
    [Documentation]             Delete the l3-network just created
    ${resp}=                    DeleteWithCert           ${L3NETWORKURL}?resource-version=${resource_version}
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
    [Documentation]             Delete the complex just created
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