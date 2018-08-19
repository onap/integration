*** settings ***
Library     Collections
Library     RequestsLibrary

*** Variables ***
@{return_ok_list}=   		200  201  202
${queryregistration_url}	/api/multicloud-pike/v0/CloudOwner_RegionOne/registry


*** Test Cases ***
OcataRegistryTest
    [Documentation]		Register openstack cloud resources
    ${headers}    		Create Dictionary	Content-Type=application/json		Accept=application/json
    Create Session		web_session		http://${SERVICE_IP}:${SERVICE_PORT}	headers=${headers}
    ${resp}=			Post Request		web_session				${queryregistration_url}
    ${response_code}=		Convert To String	${resp.status_code}
    List Should Contain Value	${return_ok_list}	${response_code}
