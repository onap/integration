*** Settings ***
Library    SSHLibrary
Library    OperatingSystem
*** Variables ***
${HOST}    104.130.138.49
${USERNAME}    test            
${private_key}    H:\\TestSuite\\testsuite\\robot\\testsuites               
*** Test Cases ***
APPC Netstat 
   Open Connection    ${HOST}
   ${password}=    Get File    ${private_key}
   Login    ${USERNAME}    ${password}
   log to console      \nConnected Successfully
   ${cmd} =    set variable    netstat -a | grep -E '8443 | grep LISTEN
   execute command     ${cmd}
       
Tear Down
    [Documentation]   Close all connections
    Close All connections