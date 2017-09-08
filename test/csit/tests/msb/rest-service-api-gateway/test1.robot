*** Settings ***
Library  Collections
Library  requests

*** Test Cases ***
REST service Test1
    [Documentation]            Check if test rest service can be accessed via aip gateway
    ${result} =  get           http://${MSB_IAG_IP}/api/test/v1/people
    Should Be Equal            ${result.status_code}       ${200}
