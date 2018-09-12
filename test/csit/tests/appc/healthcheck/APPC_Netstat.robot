*** Settings ***
Library    OperatingSystem
Library    String

*** Test Cases ***
APPC Netstat
    [Documentation]    Checking the active ports
    ${output}=     Run	netstat -a | grep -E 8282 | grep LISTEN
    Log To Console    ${output}
    ${line_count}=     Get Line Count    ${output}
    Should Be Equal As Strings    ${line_count}    1
