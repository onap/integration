*** Settings ***
Library    Selenium2Library
Library    OperatingSystem
Library    DateTime
Library    String
Library    Collections


*** Keywords ***
Get Server time
    [Documentation]    Getting server time to update the json request
    [Arguments]     ${RequestFile}    
    
    ${date}=    Get Current Date    time_zone=local    result_format=%Y-%m-%dT%H:%M:%S.%fZ    exclude_millis=False 
    
    #updating the request file with the server time
    ${file_content}=    Get File    ${RequestFile}
    @{list}=    Split to lines  ${file_content}
    ${data}=    Get from list    ${list}    5
    @{splitted_string}=    Split String    ${data}    :    1
    ${time}=    Get From List    ${splitted_string}    1
    Log    ${time}
    @{splitted_string_time}=    Split String    ${time}    "    2
    ${times1}=    Get From List    ${splitted_string_time}    1
    Log    ${times1}
    ${replaced_string}=    Replace String    ${data}    ${times1}    ${date}
    @{list1}=    Split to lines  ${file_content} 
    Remove from list    ${list1}    5
    Insert into list    ${list1}    5     ${replaced_string}
    Remove File     ${RequestFile}                                              
    :FOR    ${line}    IN    @{list1}
    \      Append to File    ${RequestFile}    ${line}    encoding=UTF-8
    \      Append to File    ${RequestFile}    ${\n}    encoding=UTF-8
