*** Settings ***
Library    SSHLibrary
Library    OperatingSystem
*** Variables ***
${HOST}    104.130.138.49
${USERNAME}    root            
${private_key}    ../integration/test/csit/tests/appc/Resources/openecomp_PrivateKey                  
*** Test Cases ***
APPC Netstat
   Open Connection    ${HOST}    
   Login with public key    ${USERNAME}    ${private_key}    4
   log to console      \nConnected Successfully
   ${output}=    execute command  netstat -a | grep -E 8443 | grep LISTEN
   Log To Console    ${output}
Tear Down
    [Documentation]   Close all connections
    Close All connections