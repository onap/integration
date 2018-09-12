*** Settings ***
Library    Selenium2Library
Library    XvfbRobot
Resource   ${CURDIR}/APPC_GLOBAL_VARIABLES.robot
Resource   ${CURDIR}/APPC_GLOBAL_KEYWORDS.robot


*** Test Cases ***
APPC LCM API VM RESTART
    [Documentation]    APPC LCM API VM RESTART
    [Teardown]    Close All Browsers
    Start Virtual Display     1920     1080
    Open Browser    http://${GLOBAL_APPC_ADMIN_USER}:${GLOBAL_APPC_ADMIN_PASS}@localhost:8282/apidoc/explorer/index.html    chrome
    Set Window Size    1920    1080
#    Click Element    xpath=.//p[contains(text(),'If you have reason to expect the website is safe, select the I Accept the Risk button to continue.')]//following::img

    Reload Page

#    Wait Until Page Contains Element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a  
#    Set Selenium Speed    60
#    Click Element     xpath=.//*[contains(text(),'appc-provider-lcm(2016-01-08)')]

#    Wait Until Page Contains Element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]        
#    Set Selenium Speed    60
#    Click Element     xpath=.//*[contains(text(),'appc-provider-lcm:restart')]

#   Get Server time    ${GLOBAL_VM_RESTART_REQUESTFILE}   
   
#   ${file_content}=    OperatingSystem.Get File    ${GLOBAL_VM_RESTART_REQUESTFILE}
    
#    Wait Until Page Contains Element    xpath=//td[contains(text(), '(restart)input-TOP')]//following::textarea[@name='(restart)input-TOP'][3]
#    Set Selenium Speed    90
#    Input Text       xpath=(.//*[contains(text(),'(restart)input-TOP')])[5]/following::textarea[1]    ${file_content} 
#    Input Text     xpath= //td[contains(text(), '(restart)input-TOP')]//following::textarea[@name='(restart)input-TOP'][3]      ${file_content}

#    Click Element     xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]//following::form/div[2]/input[1]

#    ${var}=    Get Value    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]//following::h4[contains(text(),'Response Code')][1]//following-sibling::div//pre
#    Element Text Should Be     xpath=//*[contains(text(),'/operations/appc-provider-lcm:restart')]//following::h4[text()='Response Code'][1]//following-sibling::div//pre[1][text()='200']     200     expected
