*** settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
@{return_ok_list}=   		200  201  202
${queryregistration_url}	/api/multicloud-ocata/v0/windriver-hudson-dc_RegionOne/registry


*** Test Cases ***
OcataRegistryTest
    [Documentation]		Register openstack cloud resources
    ${headers}    		Create Dictionary	Content-Type=application/json		Accept=application/json
    Create Session		web_session		http://${SERVICE_IP}:${SERVICE_PORT}	headers=${headers}
    ${resp}=			Get Request		web_session				${queryregistration_url}
    ${response_code}=		Convert To String	${resp.status_code}
    List Should Contain Value	${return_ok_list}	${response_code}
    ${response_json}		json.loads		${resp.content}
    ${swagger_version}=		Convert To String	${response_json['swagger']}
    Should Be Equal		${swagger_version}	2.0
