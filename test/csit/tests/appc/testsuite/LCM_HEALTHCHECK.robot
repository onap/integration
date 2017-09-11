*** Settings ***
Library    Selenium2Library
Library    OperatingSystem

*** Variable ***
${ResponseCode}
${var}
${RequestJSON}    C:\\RobotSampleForLearning\\LearningSamples\\Resources\\Healthchk.json


*** Test Cases ***
    
APPC LCM Health check
	[Documentation]	APPC HealthCheck 
	Open Browser    http://admin:Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U@104.130.138.49:8282/apidoc/explorer/index.html    chrome
	Click Element    xpath=.//p[contains(text(),'If you have reason to expect the website is safe, select the I Accept the Risk button to continue.')]//following::img
	
	Wait Until Page Contains Element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a   
	Click Element     xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a
	
	wait until page contains element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:health-check')]
	Click Element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:health-check')]
	
	${HealthChk}=    Get File    ${RequestJSON}
	wait until page contains element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:health-check')]//following::table
	Input Text     xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:health-check')]//following::table//tbody/tr/td[2]/textarea    ${HealthChk}
	
	wait until page contains element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:health-check')]//following::form/div[2]/input[1]
	Click Element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:health-check')]//following::form/div[2]/input[1]
	
Tear Down
    [Documentation]   Close all browsers
    Close All Browsers