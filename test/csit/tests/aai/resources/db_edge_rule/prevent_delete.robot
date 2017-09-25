*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       requests
Library       Collections

*** Variables ***
${CRKEYVALUE7}       cr-integration-test7
${CRKEYVALUE8}       cr-integration-test8
${TENANTKEYVALUE}    tenant-integration-test7
${VSERVERKEYVALUE}   vserver-integration-test7

${CRURL}             https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/cloud-regions/cloud-region/${CRKEYVALUE7}/${CRKEYVALUE8}
${TENANTURL}         https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/cloud-regions/cloud-region/${CRKEYVALUE7}/${CRKEYVALUE8}/tenants/tenant/${TENANTKEYVALUE}
${VSERVERURL}        https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/cloud-regions/cloud-region/${CRKEYVALUE7}/${CRKEYVALUE8}/tenants/tenant/${TENANTKEYVALUE}/vservers/vserver/${VSERVERKEYVALUE}
${CRDATA}  {"cloud-owner":"${CRKEYVALUE7}","cloud-region-id":"${CRKEYVALUE8}","owner-defined-type":"example-owner-defined-type-98787654321-09","cloud-region-version":"example-cloud-region-version-98765784321-09","identity-url":"example-identity-url-98765437821-09","cloud-zone":"example-cloud-zone-98765784321-09","complex-name":"example-complex-name-98765874321-09"}
${TENANTDATA}  {"tenant-id":"${TENANTKEYVALUE}","tenant-name":"example-tenant-name-val-143742","vservers":{"vserver":[{"vserver-id":"${VSERVERKEYVALUE}","vserver-name":"example-vserver-name-val-357201","vserver-name2":"example-vserver-name2-val-672821","prov-status":"example-prov-status-val-137711","vserver-selflink":"example-vserver-selflink-val-58731","in-maint":true,"is-closed-loop-disabled":true}]}}


*** Test Cases ***
Run AAI Put cloud-region
    [Documentation]             Create an cloud-region object
    ${resp}=                    PutWithCert              ${CRURL}              ${CRDATA}
    log                         ${CRURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201
	
Run AAI Put tenant
    [Documentation]             Create an tenant object
    ${resp}=                    PutWithCert              ${TENANTURL}              ${TENANTDATA}
    log                         ${TENANTURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201

Run AAI Get tenant to delete
    [Documentation]             Get tenant object to delete
    ${resp}                     GetWithCert              ${TENANTURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete tenant
    [Documentation]             Delete the tenant
    ${resp}=                    DeleteWithCert           ${TENANTURL}?resource-version=${resource_version}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      400
	
Run AAI Get vserver to delete
    [Documentation]             Get vserver object to delete
    ${resp}                     GetWithCert              ${VSERVERURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete vserver
    [Documentation]             Delete the vserver
    ${resp}=                    DeleteWithCert           ${VSERVERURL}?resource-version=${resource_version}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      204
		
Run AAI Get tenant to delete
    [Documentation]             Get tenant object to delete
    ${resp}                     GetWithCert              ${TENANTURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete tenant
    [Documentation]             Delete the tenant
    ${resp}=                    DeleteWithCert           ${TENANTURL}?resource-version=${resource_version}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      204	
	
Run AAI Get cr to delete
    [Documentation]             Get cr object to delete
    ${resp}                     GetWithCert              ${CRURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete cr
    [Documentation]             Delete the cr
    ${resp}=                    DeleteWithCert           ${CRURL}?resource-version=${resource_version}
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