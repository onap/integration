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

Portal Health Check    
     Run Portal Health Check


Portal Admin functionality 
    [Documentation]    ONAP Portal Admin functionality  test
    Setup Browser
     Portal admin Login To Portal GUI
    Portal admin Microservice Onboarding
    Portal Admin Create Widget for All users
    Portal Admin Delete Widget for All users 
    Portal Admin Create Widget for Application Roles
    Portal Admin Delete Widget for Application Roles 
    Portal admin Add Application admin User New user
    Portal admin Add Standard User New user
    Portal admin Add Application Admin Exiting User -APPDEMO
    Portal admin Add Application Admin Exiting User 
    Portal admin Delete Application Admin Existing User
    Portal Admin Delete Widget for All users
    Portal admin Add Standard User Existing user  
    Portal admin Edit Standard User Existing user 
    Portal admin Delete Standard User Existing user
    Functional Top Menu Get Access   
    Functional Top Menu Contact Us
    Portal admin Edit Functional menu
    ${AdminBroadCastMsg}=    Portal Admin Broadcast Notifications 
    set global variable    ${AdminBroadCastMsg}
    ${AdminCategoryMsg}=   Portal Admin Category Notifications
    set global variable    ${AdminCategoryMsg}
    Portal admin Logout from Portal GUI
    
    
Application Admin functionality 
   [Documentation]    ONAP Application Admin functionality test 
   Application admin Login To Portal GUI
#   Application Admin Navigation Application Link Tab 
#  Application Admin Navigation Functional Menu
   Application admin Add Standard User Existing user  
   Application admin Edit Standard User Existing user 
   Application admin Delete Standard User Existing user
   Application admin Logout from Portal GUI
    
Standared User functionality 
    [Documentation]    ONAP Standared User functionality test     
     Standared user Login To Portal GUI
#     Standared user Navigation Application Link Tab
#     Standared user Navigation Functional Menu 
     Standared user Broadcast Notifications    ${AdminBroadCastMsg} 
     Standared user Category Notifications    ${AdminCategoryMsg} 
   
Teardown  
    [Documentation]    Close All Open browsers     
    Close All Browsers   
    

    

    

*** Keywords ***
