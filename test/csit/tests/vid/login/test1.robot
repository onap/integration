*** Settings ***
Documentation    This is RobotFrame work script
Library    ExtendedSelenium2Library
Library    OperatingSystem
Resource   ../resources/browser_setup.robot
#Resource    ../resources/Portal/portal_int_par.robot
Resource    ../resources/Portal/portal_VID.robot
#Resource    ../resources/Portal/portal_SDC.robot


*** Variables ***


*** Test Cases ***

Standared User functionality 
    [Documentation]    ONAP Standared User functionality test     
     Standared user Login To Portal GUI
#     Standared user Navigation Application Link Tab
#     Standared user Navigation Functional Menu 
     #Standared user Broadcast Notifications    ${AdminBroadCastMsg} 
     #Standared user Category Notifications    ${AdminCategoryMsg} 
   
Teardown  
    [Documentation]    Close All Open browsers     
    Close All Browsers   
    

    

    

*** Keywords ***
