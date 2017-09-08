*** Settings ***
Library  Collections
Library  requests

*** Test Cases ***
Messag Broker Test
    [Documentation]            Check if the test service enpoint can be get from MSB
    ${result} =  get           http://${MSB_DISCOVERY_IP}:10081/api/microservices/v1/services/test/version/v1
    Should Be Equal            ${result.status_code}       ${200}
	${json} =                  Set Variable                ${result.json()}
    ${serviceName} =           Get From Dictionary         ${json}              serviceName
    ${protocol} =              Get From Dictionary         ${json}              protocol
    Should Be Equal            ${serviceName}              test
    Should Be Equal            ${protocol}                 REST  