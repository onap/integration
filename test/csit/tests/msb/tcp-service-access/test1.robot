*** Settings ***
Library  Collections
Library  requests

*** Test Cases ***
Messag Broker Test1
    [Documentation]            Check if ActiveMQ index page can be accessed
    ${result} =  get           http://${MSB_DISCOVERY_IP}:10081/api/microservices/v1/services/ActiveMQ/version/null
    Should Be Equal            ${result.status_code}       ${200}
	${json} =                  Set Variable                ${result.json()}
    ${activeMQ_ip} =           Set Variable                ${json["nodes"][0]["ip"]}
    ${activeMQ_port} =         Set Variable                ${json["nodes"][0]["port"]}

    ${result} =  get           http://${activeMQ_ip}:8161
    Should Be Equal            ${result.status_code}       ${200}

