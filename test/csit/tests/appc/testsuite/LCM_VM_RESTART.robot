*** Settings ***
Library    Selenium2Library
Library    OperatingSystem

*** Variable ***
${ResponseCode}
${var}
${RequestJSON}    /LearningSamples/Resources/VMRestart.json


*** Test Cases ***
    
APPC API VM RESTART
	[Documentation]	APPC VM LCM Restart 
	Open Browser    http://admin:Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U@104.130.138.49:8282/apidoc/explorer/index.html    chrome 
	Click Element    xpath=.//p[contains(text(),'If you have reason to expect the website is safe, select the I Accept the Risk button to continue.')]//following::img
	Click Element     xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a
	Click Element     xpath=//*[@id="appc-provider-lcm(2016-01-08)_restart_post_23"]/div[1]/h3/span[2]/a
	${VM_LCM_RESTART}     Get File    ${RequestJSON}
	Input Text     xpath=//*[@id="appc-provider-lcm(2016-01-08)_restart_post_23_content"]/form/table/tbody/tr/td[2]/textarea     ${VM_LCM_RESTART}
	Click Element     xpath=//*[@id="appc-provider-lcm(2016-01-08)_restart_post_23_content"]/form/div[2]/input
	# Get Text locator
	${ResponseCode}    Get Text     xpath=//*[@id="appc-provider-lcm(2016-01-08)_restart_post_23_content"]/div[2]/h4[contains(text(),'Response Code')]//following::div//pre
	${var}    Get Value    xpath=//*[@id="appc-provider-lcm(2016-01-08)_restart_post_23_content"]/div[2]/h4[contains(text(),'Response Code')]//following::div//pre
	Log     Value-->    ${ResponseCode}
	Log     var-->    ${var}
	Element Text Should Be     xpath=//*[@id="appc-provider-lcm(2016-01-08)_restart_post_23_content"]/div[2]/h4[contains(text(),'Response Code')]//following::div//pre     400     expected
	
Tear Down
    [Documentation]   Close all browsers
    Close All Browsers