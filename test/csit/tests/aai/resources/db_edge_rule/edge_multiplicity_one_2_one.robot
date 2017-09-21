*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       requests
Library       Collections

*** Variables ***
${CRKEYVALUE1}         cr-integration-test1
${CRKEYVALUE2}         cr-integration-test2
${TENANTKEYVALUE}     tenant-integration-test1
${VSERVERKEYVALUE1}   vserver-integration-test1
${VSERVERKEYVALUE2}   vserver-integration-test2
${SNAPSHOTKEYVALUE1}  snapshot-integration-test1
${SNAPSHOTKEYVALUE2}  snapshot-integration-test2

${CRURL}                  https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/cloud-regions/cloud-region/${CRKEYVALUE1}/${CRKEYVALUE2}
${TENANTURL}              https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/cloud-regions/cloud-region/${CRKEYVALUE1}/${CRKEYVALUE2}/tenants/tenant/${TENANTKEYVALUE}
${VSERVERURL1}            https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/cloud-regions/cloud-region/${CRKEYVALUE1}/${CRKEYVALUE2}/tenants/tenant/${TENANTKEYVALUE}/vservers/vserver/${VSERVERKEYVALUE1}
${VSERVERURL2}            https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/cloud-regions/cloud-region/${CRKEYVALUE1}/${CRKEYVALUE2}/tenants/tenant/${TENANTKEYVALUE}/vservers/vserver/${VSERVERKEYVALUE2}
${SNAPSHOTURL1}           https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/cloud-regions/cloud-region/${CRKEYVALUE1}/${CRKEYVALUE2}/snapshots/snapshot/${SNAPSHOTKEYVALUE1}
${SNAPSHOTURL2}           https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/cloud-regions/cloud-region/${CRKEYVALUE1}/${CRKEYVALUE2}/snapshots/snapshot/${SNAPSHOTKEYVALUE2}
${RELATIONSHIPURL1}       https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/cloud-regions/cloud-region/${CRKEYVALUE1}/${CRKEYVALUE2}/tenants/tenant/${TENANTKEYVALUE}/vservers/vserver/${VSERVERKEYVALUE1}/relationship-list/relationship
${RELATIONSHIPURL2}       https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/cloud-regions/cloud-region/${CRKEYVALUE1}/${CRKEYVALUE2}/snapshots/snapshot/${SNAPSHOTKEYVALUE1}/relationship-list/relationship
${CRDATA}  {"cloud-owner":"${CRKEYVALUE1}","cloud-region-id":"${CRKEYVALUE2}","owner-defined-type":"example-owner-defined-type-987654321-09","cloud-region-version":"example-cloud-region-version-987654321-09","identity-url":"example-identity-url-987654321-09","cloud-zone":"example-cloud-zone-987654321-09","complex-name":"example-complex-name-987654321-09"}
${TENANTDATA}  {"tenant-id":"${TENANTKEYVALUE}","tenant-name":"tenant-name-0999"}
${VSERVERDATA1}  {"vserver-id":"${VSERVERKEYVALUE1}","vserver-name":"example-vserver-name-val-7367","vserver-name2":"example-vserver-name2-val-7367","prov-status":"example-prov-status-val-7367","vserver-selflink":"example-vserver-selflink-val-7367"}
${VSERVERDATA2}  {"vserver-id":"${VSERVERKEYVALUE2}","vserver-name":"example-vserver-name-val-73678","vserver-name2":"example-vserver-name2-val-73867","prov-status":"example-prov-status-val-73867","vserver-selflink":"example-vserver-selflink-val-73687"}
${SNAPSHOTDATA1}  {"snapshot-id":"${SNAPSHOTKEYVALUE1}"}
${SNAPSHOTDATA2}  {"snapshot-id":"${SNAPSHOTKEYVALUE2}"}
${RELATIONSHIPDATA1}  {"related-to":"snapshot","relationship-data":[{"relationship-key":"snapshot.snapshot-id","relationship-value":"${SNAPSHOTKEYVALUE1}"},{"relationship-key":"cloud-region.cloud-owner","relationship-value":"${CRKEYVALUE1}"},{"relationship-key":"cloud-region.cloud-region-id","relationship-value":"${CRKEYVALUE2}"}]}
${RELATIONSHIPDATA2}  {"related-to":"snapshot","relationship-data":[{"relationship-key":"snapshot.snapshot-id","relationship-value":"${SNAPSHOTKEYVALUE2}"},{"relationship-key":"cloud-region.cloud-owner","relationship-value":"${CRKEYVALUE1}"},{"relationship-key":"cloud-region.cloud-region-id","relationship-value":"${CRKEYVALUE2}"}]}
${RELATIONSHIPDATA3}  {"related-to":"vserver","relationship-data":[{"relationship-key":"vserver.vserver-id","relationship-value":"${VSERVERKEYVALUE2}"},{"relationship-key":"tenant.tenant-id","relationship-value":"${TENANTKEYVALUE}"},{"relationship-key":"cloud-region.cloud-owner","relationship-value":"${CRKEYVALUE1}"},{"relationship-key":"cloud-region.cloud-region-id","relationship-value":"${CRKEYVALUE2}"}]}

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

Run AAI Put vserver1
    [Documentation]             Create an vserver1 object
    ${resp}=                    PutWithCert              ${VSERVERURL1}              ${VSERVERDATA1}
    log                         ${VSERVERURL1}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201

Run AAI Put vserver2
    [Documentation]             Create an vserver2 object
    ${resp}=                    PutWithCert              ${VSERVERURL2}              ${VSERVERDATA2}
    log                         ${VSERVERURL2}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201

Run AAI Put snapshot1
    [Documentation]             Create an snapshot1 object
    ${resp}=                    PutWithCert              ${SNAPSHOTURL1}              ${SNAPSHOTDATA1}
    log                         ${SNAPSHOTURL1}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201

Run AAI Put snapshot2
    [Documentation]             Create an snapshot2 object
    ${resp}=                    PutWithCert              ${SNAPSHOTURL2}              ${SNAPSHOTDATA2}
    log                         ${SNAPSHOTURL2}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201	
	
Run AAI Put relationship vserver1 and snapshot1
    [Documentation]             Create relationship vserver1 and snapshot1
    ${resp}=                    PutWithCert              ${RELATIONSHIPURL1}              ${RELATIONSHIPDATA1}
    log                         ${RELATIONSHIPURL1}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      200	
	
Run AAI Put relationship vserver1 and snapshot2 (NOT ALLOW)
    [Documentation]             Create relationship vserver1 and snapshot2 (NOT ALLOW)
    ${resp}=                    PutWithCert              ${RELATIONSHIPURL1}              ${RELATIONSHIPDATA2}
    log                         ${RELATIONSHIPURL1}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      400	
	
Run AAI Put relationship snapshot1 and vserver2 (NOT ALLOW)
    [Documentation]             Create relationship snapshot1 and vserver2 (NOT ALLOW)
    ${resp}=                    PutWithCert              ${RELATIONSHIPURL2}              ${RELATIONSHIPDATA3}
    log                         ${RELATIONSHIPURL2}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      400

Run AAI Delete relationship vserver1 and snapshot1
    [Documentation]             Delete relationship vserver1 and snapshot1
    ${resp}=                    DeleteWithCert           ${RELATIONSHIPURL1}              ${RELATIONSHIPDATA1}
    log                         ${RELATIONSHIPURL1}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      204	
	
Run AAI Get vserver1 to delete
    [Documentation]             Get vserver1 object to delete
    ${resp}                     GetWithCert              ${VSERVERURL1}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete vserver1
    [Documentation]             Delete the vserver1
    ${resp}=                    DeleteWithCert           ${VSERVERURL1}?resource-version=${resource_version}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      204
	
Run AAI Get vserver2 to delete
    [Documentation]             Get vserver2 object to delete
    ${resp}                     GetWithCert              ${VSERVERURL2}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete vserver2
    [Documentation]             Delete the vserver2
    ${resp}=                    DeleteWithCert           ${VSERVERURL2}?resource-version=${resource_version}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      204

Run AAI Get snapshot1 to delete
    [Documentation]             Get snapshot1 object to delete
    ${resp}                     GetWithCert              ${SNAPSHOTURL1}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete snapshot1
    [Documentation]             Delete the snapshot1
    ${resp}=                    DeleteWithCert           ${SNAPSHOTURL1}?resource-version=${resource_version}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      204	
	
Run AAI Get snapshot2 to delete
    [Documentation]             Get snapshot2 object to delete
    ${resp}                     GetWithCert              ${SNAPSHOTURL2}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete snapshot2
    [Documentation]             Delete the snapshot2
    ${resp}=                    DeleteWithCert           ${SNAPSHOTURL2}?resource-version=${resource_version}
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