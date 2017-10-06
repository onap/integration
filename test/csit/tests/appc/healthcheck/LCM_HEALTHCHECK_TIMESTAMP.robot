*** Settings ***
Library    Selenium2Library
Library    OperatingSystem
Library    XvfbRobot
Resource    ${CURDIR}/APPC_GLOBAL_VARIABLES.robot		
Resource    ${CURDIR}/gettime.robot


*** Variable ***
${ResponseCode}
${var}


*** Test Cases ***
    
APPC LCM API HEALTHCHECK
	[Documentation]	APPC LCM API HEALTHCHECK 
	Start Virtual Display     1920     1080
	Open Browser    http://admin:Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U@localhost:8282/apidoc/explorer/index.html	chrome
	Maximize Browser Window 
#	Click Element    xpath=.//p[contains(text(),'If you have reason to expect the website is safe, select the I Accept the Risk button to continue.')]//following::img
	
	Wait Until Page Contains Element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a   
#	Set Selenium Speed	60
	Click Element     xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a

	wait until page contains element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:health-check')]
#	Set Selenium Speed	60
	Click link    xpath=//*[@id="appc-provider-lcm(2016-01-08)_health_check_post_0"]/div[1]/h3/span[2]/a
	
	Get Server time    ${GLOBAL_HEALTHCHECK_REQUESTFILE}
	${file_content}=    OperatingSystem.Get File    ${GLOBAL_HEALTHCHECK_REQUESTFILE}
    
	wait until page contains element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:health-check')]//following::table
	Input Text     xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:health-check')]//following::table//tbody/tr/td[2]/textarea    ${file_content}
	
	wait until page contains element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:health-check')]//following::form/div[2]/input[1]
	Click Element    xpath=//*[@id="appc-provider-lcm(2016-01-08)_health_check_post_0_content"]/form/div[2]/input
	
	Wait until page contains element    xpath=//*[@id="appc-provider-lcm(2016-01-08)_health_check_post_0_content"]/div[2]/div[3]/pre[1][text()='200']
	
	${var}=    Get Value    xpath= //*[@id="appc-provider-lcm(2016-01-08)_health_check_post_0_content"]/div[2]/div[3]/pre
	Element Text Should Be     xpath=//*[@id="appc-provider-lcm(2016-01-08)_health_check_post_0_content"]/div[2]/div[3]/pre[1][text()='200']     200     expected
	
Tear Down
   [Documentation]   Close all browsers
    Close All Browsers