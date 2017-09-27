*** Settings ***
Library       OperatingSystem
Library       RequestsLibrary
Library       requests
Library       Collections

*** Variables ***
${GENERICVNFKEYVALUE}  generic-vnf-integration-test1
${PSERVERKEYVALUE}     pserver-integration-test1
${GENERICVNFURL}       https://${HOST_IP}:8443/aai/v11/network/generic-vnfs/generic-vnf/${GENERICVNFKEYVALUE}
${PSERVERURL}          https://${HOST_IP}:8443/aai/v11/cloud-infrastructure/pservers/pserver/${PSERVERKEYVALUE}
${RELATIONSHIPURL}     https://${HOST_IP}:8443/aai/v11/network/generic-vnfs/generic-vnf/${GENERICVNFKEYVALUE}/relationship-list/relationship
${CUSTOMQUERYURL}      https://${HOST_IP}:8443/aai/v11/query?format=simple
${GENERICVNFDATA}  { "vnf-id": "generic-vnf-integration-test1", "vnf-name": "example-vnf-name-val-51663", "vnf-name2": "example-vnf-name2-val-15450", "vnf-type": "example-vnf-type-val-32726", "service-id": "example-service-id-val-49385", "regional-resource-zone": "example-regional-resource-zone-val-41257", "prov-status": "example-prov-status-val-5666", "operational-status": "example-operational-status-val-95008", "license-key": "example-license-key-val-25823", "equipment-role": "example-equipment-role-val-30138", "orchestration-status": "example-orchestration-status-val-18897", "heat-stack-id": "example-heat-stack-id-val-46807", "mso-catalog-key": "example-mso-catalog-key-val-43833", "management-option": "example-management-option-val-92040", "ipv4-oam-address": "example-ipv4-oam-address-val-85170", "ipv4-loopback0-address": "example-ipv4-loopback0-address-val-88650", "nm-lan-v6-address": "example-nm-lan-v6-address-val-76997", "management-v6-address": "example-management-v6-address-val-10065", "vcpu": 5182376, "vcpu-units": "example-vcpu-units-val-52149", "vmemory": 35401466, "vmemory-units": "example-vmemory-units-val-46534", "vdisk": 74255232, "vdisk-units": "example-vdisk-units-val-83649", "in-maint": true, "is-closed-loop-disabled": true, "summary-status": "example-summary-status-val-99435", "encrypted-access-flag": true, "entitlement-assignment-group-uuid": "example-entitlement-assignment-group-uuid-val-50758", "entitlement-resource-uuid": "example-entitlement-resource-uuid-val-21058", "license-assignment-group-uuid": "example-license-assignment-group-uuid-val-99092", "license-key-uuid": "example-license-key-uuid-val-93512", "nf-naming-code": "example-nf-naming-code-val-89", "selflink": "example-selflink-val-42557", "ipv4-oam-gateway-address": "example-ipv4-oam-gateway-address-val-50012", "ipv4-oam-gateway-address-prefix-length": 92759, "vlan-id-outer": 20604980, "nm-profile-name": "example-nm-profile-name-val-35055" }
${PSERVERDATA}  {"hostname":"${PSERVERKEYVALUE}","ptnii-equip-name":"example-ptnii-equip-name-val-34642","number-of-cpus":84692,"disk-in-gigabytes":21548,"ram-in-megabytes":2010,"equip-type":"example-equip-type-val-46868","equip-vendor":"example-equip-vendor-val-58378","equip-model":"example-equip-model-val-49667","fqdn":"example-fqdn-val-58266","pserver-selflink":"example-pserver-selflink-val-80113","ipv4-oam-address":"example-ipv4-oam-address-val-71608","serial-number":"example-serial-number-val-34523","ipaddress-v4-loopback-0":"example-ipaddress-v4-loopback0-val-4173","ipaddress-v6-loopback-0":"example-ipaddress-v6-loopback0-val-62206","ipaddress-v4-aim":"example-ipaddress-v4-aim-val-41298","ipaddress-v6-aim":"example-ipaddress-v6-aim-val-96514","ipaddress-v6-oam":"example-ipaddress-v6-oam-val-78247","inv-status":"example-inv-status-val-93966","pserver-id":"example-pserver-id-val-47577","internet-topology":"example-internet-topology-val-65227","in-maint":true,"pserver-name2":"example-pserver-name2-val-94504","purpose":"example-purpose-val-25201","prov-status":"example-prov-status-val-79019","management-option":"example-management-option-val-86438","host-profile":"example-host-profile-val-93838","p-interfaces":{"p-interface":[{"interface-name":"example-interface-name-val-55444","speed-value":"example-speed-value-val-30765","speed-units":"example-speed-units-val-48515","port-description":"example-port-description-val-96959","equipment-identifier":"example-equipment-identifier-val-19416","interface-role":"example-interface-role-val-63688","interface-type":"example-interface-type-val-54743","prov-status":"example-prov-status-val-52065","in-maint":true,"inv-status":"example-inv-status-val-42783","sriov-pfs":{"sriov-pf":[{"pf-pci-id":"example-pf-pci-id-val-74864"}]},"l-interfaces":{"l-interface":[{"interface-name":"example-interface-name-val-22388","interface-role":"example-interface-role-val-58147","v6-wan-link-ip":"example-v6-wan-link-ip-val-95446","selflink":"example-selflink-val-98510","interface-id":"example-interface-id-val-4590","macaddr":"example-macaddr-val-30191","network-name":"example-network-name-val-78823","management-option":"example-management-option-val-23012","interface-description":"example-interface-description-val-55442","is-port-mirrored":true,"in-maint":true,"prov-status":"example-prov-status-val-94418","is-ip-unnumbered":true,"allowed-address-pairs":"example-allowed-address-pairs-val-28004","vlans":{"vlan":[{"vlan-interface":"example-vlan-interface-val-25336","vlan-id-inner":26236564,"vlan-id-outer":46928574,"speed-value":"example-speed-value-val-27478","speed-units":"example-speed-units-val-70336","vlan-description":"example-vlan-description-val-92660","backdoor-connection":"example-backdoor-connection-val-66277","vpn-key":"example-vpn-key-val-4325","orchestration-status":"example-orchestration-status-val-49334","in-maint":true,"prov-status":"example-prov-status-val-30145","is-ip-unnumbered":true,"l3-interface-ipv4-address-list":[{"l3-interface-ipv4-address":"example-l3-interface-ipv4-address-val-7810","l3-interface-ipv4-prefix-length":21802495,"vlan-id-inner":93457355,"vlan-id-outer":69279959,"is-floating":true,"neutron-network-id":"example-neutron-network-id-val-43588","neutron-subnet-id":"example-neutron-subnet-id-val-30646"}],"l3-interface-ipv6-address-list":[{"l3-interface-ipv6-address":"example-l3-interface-ipv6-address-val-33011","l3-interface-ipv6-prefix-length":42660850,"vlan-id-inner":98698343,"vlan-id-outer":61912209,"is-floating":true,"neutron-network-id":"example-neutron-network-id-val-33882","neutron-subnet-id":"example-neutron-subnet-id-val-12327"}]}]},"sriov-vfs":{"sriov-vf":[{"pci-id":"example-pci-id-val-29862","vf-vlan-filter":"example-vf-vlan-filter-val-46369","vf-mac-filter":"example-vf-mac-filter-val-68489","vf-vlan-strip":true,"vf-vlan-anti-spoof-check":true,"vf-mac-anti-spoof-check":true,"vf-mirrors":"example-vf-mirrors-val-70037","vf-broadcast-allow":true,"vf-unknown-multicast-allow":true,"vf-unknown-unicast-allow":true,"vf-insert-stag":true,"vf-link-status":"example-vf-link-status-val-81133","neutron-network-id":"example-neutron-network-id-val-99772"}]},"l-interfaces":{"l-interface":[{"interface-name":"example-interface-name-val-91143","interface-role":"example-interface-role-val-26018","v6-wan-link-ip":"example-v6-wan-link-ip-val-84852","selflink":"example-selflink-val-67850","interface-id":"example-interface-id-val-42475","macaddr":"example-macaddr-val-97398","network-name":"example-network-name-val-65143","management-option":"example-management-option-val-68439","interface-description":"example-interface-description-val-66196","is-port-mirrored":true,"in-maint":true,"prov-status":"example-prov-status-val-48504","is-ip-unnumbered":true,"allowed-address-pairs":"example-allowed-address-pairs-val-43520"}]},"l3-interface-ipv4-address-list":[{"l3-interface-ipv4-address":"example-l3-interface-ipv4-address-val-39495","l3-interface-ipv4-prefix-length":12965894,"vlan-id-inner":96693573,"vlan-id-outer":36602994,"is-floating":true,"neutron-network-id":"example-neutron-network-id-val-30471","neutron-subnet-id":"example-neutron-subnet-id-val-37707"}],"l3-interface-ipv6-address-list":[{"l3-interface-ipv6-address":"example-l3-interface-ipv6-address-val-39521","l3-interface-ipv6-prefix-length":79936773,"vlan-id-inner":18996980,"vlan-id-outer":57829188,"is-floating":true,"neutron-network-id":"example-neutron-network-id-val-7824","neutron-subnet-id":"example-neutron-subnet-id-val-32242"}]}]}}]},"lag-interfaces":{"lag-interface":[{"interface-name":"example-interface-name-val-14958","interface-description":"example-interface-description-val-53147","speed-value":"example-speed-value-val-40106","speed-units":"example-speed-units-val-3241","interface-id":"example-interface-id-val-41963","interface-role":"example-interface-role-val-36210","prov-status":"example-prov-status-val-86993","in-maint":true,"l-interfaces":{"l-interface":[{"interface-name":"example-interface-name-val-68784","interface-role":"example-interface-role-val-27031","v6-wan-link-ip":"example-v6-wan-link-ip-val-84237","selflink":"example-selflink-val-18671","interface-id":"example-interface-id-val-39357","macaddr":"example-macaddr-val-18618","network-name":"example-network-name-val-69761","management-option":"example-management-option-val-97287","interface-description":"example-interface-description-val-11299","is-port-mirrored":true,"in-maint":true,"prov-status":"example-prov-status-val-17553","is-ip-unnumbered":true,"allowed-address-pairs":"example-allowed-address-pairs-val-94432","vlans":{"vlan":[{"vlan-interface":"example-vlan-interface-val-6087","vlan-id-inner":73148506,"vlan-id-outer":96154645,"speed-value":"example-speed-value-val-25656","speed-units":"example-speed-units-val-56493","vlan-description":"example-vlan-description-val-41479","backdoor-connection":"example-backdoor-connection-val-1426","vpn-key":"example-vpn-key-val-51806","orchestration-status":"example-orchestration-status-val-55778","in-maint":true,"prov-status":"example-prov-status-val-74154","is-ip-unnumbered":true,"l3-interface-ipv4-address-list":[{"l3-interface-ipv4-address":"example-l3-interface-ipv4-address-val-19626","l3-interface-ipv4-prefix-length":61568821,"vlan-id-inner":29070594,"vlan-id-outer":70606591,"is-floating":true,"neutron-network-id":"example-neutron-network-id-val-66780","neutron-subnet-id":"example-neutron-subnet-id-val-55672"}],"l3-interface-ipv6-address-list":[{"l3-interface-ipv6-address":"example-l3-interface-ipv6-address-val-36704","l3-interface-ipv6-prefix-length":63868876,"vlan-id-inner":9280699,"vlan-id-outer":77194996,"is-floating":true,"neutron-network-id":"example-neutron-network-id-val-73242","neutron-subnet-id":"example-neutron-subnet-id-val-34450"}]}]},"sriov-vfs":{"sriov-vf":[{"pci-id":"example-pci-id-val-8918","vf-vlan-filter":"example-vf-vlan-filter-val-24017","vf-mac-filter":"example-vf-mac-filter-val-10153","vf-vlan-strip":true,"vf-vlan-anti-spoof-check":true,"vf-mac-anti-spoof-check":true,"vf-mirrors":"example-vf-mirrors-val-76723","vf-broadcast-allow":true,"vf-unknown-multicast-allow":true,"vf-unknown-unicast-allow":true,"vf-insert-stag":true,"vf-link-status":"example-vf-link-status-val-2457","neutron-network-id":"example-neutron-network-id-val-56687"}]},"l-interfaces":{"l-interface":[{"interface-name":"example-interface-name-val-18097","interface-role":"example-interface-role-val-32400","v6-wan-link-ip":"example-v6-wan-link-ip-val-34470","selflink":"example-selflink-val-41000","interface-id":"example-interface-id-val-87031","macaddr":"example-macaddr-val-14216","network-name":"example-network-name-val-94824","management-option":"example-management-option-val-84161","interface-description":"example-interface-description-val-98603","is-port-mirrored":true,"in-maint":true,"prov-status":"example-prov-status-val-8165","is-ip-unnumbered":true,"allowed-address-pairs":"example-allowed-address-pairs-val-7400"}]},"l3-interface-ipv4-address-list":[{"l3-interface-ipv4-address":"example-l3-interface-ipv4-address-val-99504","l3-interface-ipv4-prefix-length":1377494,"vlan-id-inner":26972619,"vlan-id-outer":30216510,"is-floating":true,"neutron-network-id":"example-neutron-network-id-val-40697","neutron-subnet-id":"example-neutron-subnet-id-val-36665"}],"l3-interface-ipv6-address-list":[{"l3-interface-ipv6-address":"example-l3-interface-ipv6-address-val-99805","l3-interface-ipv6-prefix-length":73740394,"vlan-id-inner":70722364,"vlan-id-outer":28049066,"is-floating":true,"neutron-network-id":"example-neutron-network-id-val-56654","neutron-subnet-id":"example-neutron-subnet-id-val-43360"}]}]}}]}}
${RELATIONSHIPDATA} {"related-to":"pserver","relationship-data":[{"relationship-key":"pserver.hostname","relationship-value":"${PSERVERKEYVALUE}"}]}
${CUSTOMQUERYDATA}  {"gremlin":"g.V().has('hostname', '${PSERVERKEYVALUE}')"}

*** Test Cases ***

Run AAI Put generic-vnf
    [Documentation]             Create an generic-vnf object
    ${resp}=                    PutWithCert              ${GENERICVNFURL}              ${GENERICVNFDATA}
    log                         ${GENERICVNFURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201
	
Run AAI Put pserver
    [Documentation]             Create an pserver object
    ${resp}=                    PutWithCert              ${PSERVERURL}              ${PSERVERDATA}
    log                         ${PSERVERURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      201	
	
Run AAI Put relationship of pserver and generic-vnf
    [Documentation]             Create relationship of pserver and generic-vnf
    ${resp}=                    PutWithCert              ${RELATIONSHIPURL}              ${RELATIONSHIPDATA}
    log                         ${RELATIONSHIPURL}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      200

Run AAI Get pserver
    [Documentation]             Get the pserver object just relationship
    ${resp}                     GetWithCert              ${PSERVERURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200	
	
Run AAI Get generic-vnf
    [Documentation]             Get the generic-vnf object just relationship
    ${resp}                     GetWithCert              ${GENERICVNFURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200	
	
Run AAI Put custom query simple format
    [Documentation]             custom query simple format
    ${resp}=                    PutWithCert              ${CUSTOMQUERYURL}              ${CUSTOMQUERYDATA}
    log                         ${CUSTOMQUERYURL}
    log                         ${resp.text}
	log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
	
Run AAI Get generic-vnf to delete
    [Documentation]             Get the generic-vnf object to delete
    ${resp}                     GetWithCert              ${GENERICVNFURL}
    log                         ${resp}
    log                         ${resp.json()}
    Should Be Equal As Strings  ${resp.status_code}      200
    ${resource_version}=        Evaluate                 $resp.json().get('resource-version')
    Set Global Variable			${resource_version}

Run AAI Delete generic-vnf
    [Documentation]             Delete the generic-vnf
    ${resp}=                    DeleteWithCert           ${GENERICVNFURL}?resource-version=${resource_version}
    log                         ${resp.text}
    Should Be Equal As Strings  ${resp.status_code}      204
	
Run AAI Get pserver to delete
    [Documentation]             Get the pserver object to delete
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
