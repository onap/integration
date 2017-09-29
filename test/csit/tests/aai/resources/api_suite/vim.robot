*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       requests
Library       Collections

*** Variables ***
${TARGETURL}  https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/cloud-regions/cloud-region/VIM-test1/RegionOne1
${VIMDATA}  {"cloud-owner": "VIM-test1", "cloud-region-id": "RegionOne1", "cloud-type": "openstack", "owner-defined-type": "owner-defined-type", "cloud-region-version": "v1.0", "cloud-zone": "cloud zone", "complex-name": "complex name", "cloud-extra-info": "{}", "esr-system-info-list": { "esr-system-info": [{"esr-system-info-id": "vim-esr-system-info-id", "service-url": "http://10.12.25.2:5000/v3", "user-name": "demo", "password": "onapdemo", "system-type": "VIM", "ssl-insecure": true, "cloud-domain": "Default"}]}
}

*** Test Cases ***

Run AAI Put VIM
    [Documentation]             Create an VIM object
    ${resp}=                    PutWithCert              ${TARGETURL}              ${VIMDATA}
    log                         ${TARGETURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201

Run AAI Get VIM
    [Documentation]             Get the VIM object just created
    ${resp}                     GetWithCert              ${TARGETURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete VIM
    [Documentation]             Delete the VIM just created
    ${resp}=                    DeleteWithCert           ${TARGETURL}?resource-version=${resource_version}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      204

*** Keywords ***
PutWithCert
    [Arguments]      ${url}      ${data}
    ${headers}=      Create Dictionary     Accept=application/json    Content-Type=application/json    X-TransactionId=integration-aai    X-FromAppId=integration-aai   Authorization=Basic QUFJOkFBSQ==
    ${certinfo}=     Evaluate    ('${CURDIR}/aai.crt', '${CURDIR}/aai.key')
    ${resp}=         Evaluate    requests.put('${url}', data='${data}', headers=${headers}, cert=${certinfo}, verify=False)    requests
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
    
