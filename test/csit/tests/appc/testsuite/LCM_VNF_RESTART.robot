*** Settings ***
Library    Selenium2Library
Library    OperatingSystem

*** Variable ***
${ResponseCode}
${var}
${RequestJSON}    C:\\RobotSampleForLearning\\LearningSamples\\Resources\\VNFRestart.json


*** Test Cases ***
    
APPC API VM RESTART
	[Documentation]	APPC VM LCM Restart 
	Open Browser    http://admin:Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U@104.130.138.49:8282/apidoc/explorer/index.html    chrome 
	Click Element    xpath=.//p[contains(text(),'If you have reason to expect the website is safe, select the I Accept the Risk button to continue.')]//following::img
	
	Wait Until Page Contains Element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a   
	Click Element     xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a
	
	
	Wait Until Page Contains Element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]        
	Click Element     xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]
	
	
	${VNF_LCM_RESTART}=     Get File    ${RequestJSON}
	Wait Until Page Contains Element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]//following::table
	
	Input Text     xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]//following::table//tbody/tr/td[2]/textarea     ${VNF_LCM_RESTART}
	
	# Wait Until Page Contains Element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]/form/div[2]/input    
	Click Element     xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]//following::form/div[2]/input[1]
	
	# Get Text locator
	${ResponseCode}    Get Text     xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]//following::h4[contains(text(),'Response Code')][1]//following-sibling::div//pre
	
	# //*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]//following::h4[contains(text(),'Response Code')]//following-sibling::div//pre
	${var}    Get Value    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:restart')]//following::h4[contains(text(),'Response Code')][1]//following-sibling::div//pre
	Log     Value-->    ${ResponseCode}
	Log     var-->    ${var}
	Element Text Should Be     xpath=//*[contains(text(),'/operations/appc-provider-lcm:restart')]//following::h4[text()='Response Code'][1]//following-sibling::div//pre[1]     200     expected
	
Tear Down
    [Documentation]   Close all browsers
    Close All Browsers