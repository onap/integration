*** Settings ***
Library     keywords.py
*** Variables ***


*** Test Cases ***
Connection to SO is performed using HTTPS
     ${cookies}=  Login To VID
     ${response}=  Send create VF module instance request to VID  ${cookies}
     Assert request has finished with 200  ${response}
     Assert returned response was as expected  ${response}


*** Keywords ***
