*** Settings ***
Library    Selenium2Library
Library    OperatingSystem
Library    XvfbRobot
Resource    APPC_GLOBAL_VARIABLES.robot
Resource    gettime.robot

*** Variable ***
${ResponseCode}
${var}

*** Test Cases ***
    
APPC LCM API HEALTHCHECK
	[Documentation]	APPC LCM API HEALTHCHECK 
	Start Virtual Display     1920     1080
	Open Browser    http://admin:Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U@localhost:8282/apidoc/explorer/index.html	chrome
#	Maximize Browser Window 
#	Click Element    xpath=.//p[contains(text(),'If you have reason to expect the website is safe, select the I Accept the Risk button to continue.')]//following::img

	Reload Page

#	Wait Until Page Contains Element    xpath=.//*[contains(text(),'appc-provider-lcm(2016-01-08)')]   

#	Set Selenium Speed	60
#	Click Element     xpath=.//*[contains(text(),'appc-provider-lcm(2016-01-08)')]

	
#	wait until page contains element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:health-check')]
#	Set Selenium Speed	60
#	Click link    xpath=.//*[contains(text(),'appc-provider-lcm(2016-01-08)')]/following::li[5]/ul/li/div[1]/h3/span[2]/a
#	Click Element    xpath=//*[@id="appc-provider-lcm(2016-01-08)_health_check_post_0"]/div[1]/h3/span[2]/a
	
#	Get Server time    ${GLOBAL_HEALTHCHECK_REQUESTFILE}
#	${file_content}=    OperatingSystem.Get File    ${GLOBAL_HEALTHCHECK_REQUESTFILE}
    
#	wait until page contains element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:health-check')]//following::table
#	Set Selenium Speed	90
#	Input Text     xpath=(.//*[contains(text(),'(health-check)input-TOP')])[1]/following::textarea[1]	${file_content} 
#	Input Text     xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:health-check')]//following::table//tbody/tr/td[2]/textarea    ${file_content}
	
#	wait until page contains element    xpath=//*[@id="resource_appc-provider-lcm(2016-01-08)"]/div/h2/a//following::a[contains(text(),'/operations/appc-provider-lcm:health-check')]//following::form/div[2]/input[1]
#	Set Selenium Speed	90
#	Click Element    xpath=//*[@id="appc-provider-lcm(2016-01-08)_health_check_post_0_content"]/form/div[2]/input
	
##	${var}=    Get Value    xpath= //*[@id="appc-provider-lcm(2016-01-08)_health_check_post_0_content"]/div[2]/div[3]/pre
##	Element Text Should Be     xpath=//*[@id="appc-provider-lcm(2016-01-08)_health_check_post_0_content"]/div[2]/div[3]/pre[1][text()='200']     200     expected
	
Tear Down

    [Documentation]   Close all browsers
    Close All Browsers
