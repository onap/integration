*** Settings ***
Library    OperatingSystem

*** Test Cases ***
APPC Netstat
    [Documentation]    Checking the active ports
    ${output}=     Run	netstat -a | grep -E 8282 | grep LISTEN
    Log To Console    ${output}
