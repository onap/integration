*** Settings ***
Library    Selenium2Library
Library    OperatingSystem
Resource   ../Resources/APPC_GLOBAL_VARIABLES.robot
Resource   ../Resources/gettime.robot
*** Variable ***
${ResponseCode}
${var}
${content}

*** Test Cases ***
APPC API VM RESTART
	[Documentation]	APPC VM LCM Restart 
	Open Browser    http://admin:Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U@%{HOST_IP}:8282/apidoc/explorer/index.html    chrome
	Maximize Browser Window
	Click Element    xpath=.//p[contains(text(),'If you have reason to expect the website is safe, select the I Accept the Risk button to continue.')]//following::img
	
	Wait Until Page Contains Element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a   
	Click Element     xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a
	
	Wait Until Page Contains Element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]        
	Click Element     xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]
	
    Get Server time    ${GLOBAL_VM_RESTART_REQUESTFILE}   
   
    ${file_content}=    OperatingSystem.Get File    ${GLOBAL_VM_RESTART_REQUESTFILE}
    
    Wait Until Page Contains Element    xpath=//td[contains(text(), '(restart)input-TOP')]//following::textarea[@name='(restart)input-TOP'][3]
    Input Text     xpath= //td[contains(text(), '(restart)input-TOP')]//following::textarea[@name='(restart)input-TOP'][3]      ${file_content}
    
	Click Element     xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]//following::form/div[2]/input[1]
	
	${var}=    Get Value    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]//following::h4[contains(text(),'Response Code')][1]//following-sibling::div//pre
	
	
	Element Text Should Be     xpath=//*[contains(text(),'/operations/appc-provider-lcm:restart')]//following::h4[text()='Response Code'][1]//following-sibling::div//pre[1][text()='200']     200     expected
	
	 
Tear Down
    [Documentation]   Close all browsers
    Close All Browsers