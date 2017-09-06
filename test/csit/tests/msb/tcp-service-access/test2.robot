*** Settings ***
Library  Collections
Library  requests
Library  Telnet 

*** Test Cases ***
Messag Broker Test2
    [Documentation]            Check if ActiveMQ listening port can be accessed
    ${result} =  get           http://${MSB_DISCOVERY_IP}:10081/api/microservices/v1/services/ActiveMQ/version/null
    Should Be Equal            ${result.status_code}       ${200}
	${json} =                  Set Variable                ${result.json()}
    ${activeMQ_ip} =           Set Variable                ${json["nodes"][0]["ip"]}
    ${activeMQ_port} =         Set Variable                ${json["nodes"][0]["port"]}
    
    Open Connection            ${activeMQ_ip}              port=${activeMQ_port}              
