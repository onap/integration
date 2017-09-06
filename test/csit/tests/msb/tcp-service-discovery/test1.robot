*** Settings ***
Library  Collections
Library  requests

*** Test Cases ***
Messag Broker Test
    [Documentation]            Check if the message broker enpoint can be get from MSB
    ${result} =  get           http://${MSB_DISCOVERY_IP}:10081/api/microservices/v1/services/ActiveMQ/version/null
    Should Be Equal            ${result.status_code}       ${200}
	${json} =                  Set Variable                ${result.json()}
    ${serviceName} =           Get From Dictionary         ${json}              serviceName
    ${protocol} =              Get From Dictionary         ${json}              protocol
    Should Be Equal            ${serviceName}              ActiveMQ
    Should Be Equal            ${protocol}                 TCP  