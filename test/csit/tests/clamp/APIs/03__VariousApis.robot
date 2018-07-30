*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${login}                     admin
${passw}                     password

*** Test Cases ***
Get Clamp properties
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/clds/cldsInfo
    Dictionary Should Contain Key    ${resp.json()}   userName
    Dictionary Should Contain Key    ${resp.json()}   permissionReadCl

Get Clamp Info
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/clds/cldsInfo
    Dictionary Should Contain Key    ${resp.json()}   userName
    Dictionary Should Contain Key    ${resp.json()}   cldsVersion

Get model bpmn by name
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/clds/model/bpmn/ClHolmes1
    Should Contain Match    ${resp}   *StartEvent_*
    Should Contain Match    ${resp}   *VesCollector_*
    Should Contain Match    ${resp}   *Holmes_*
    Should Contain Match    ${resp}   *Policy_*
    Should Contain Match    ${resp}   *EndEvent_*

Get model names
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/clds/model-names
    Should Contain Match    ${resp}   *ClHolmes1*
    Should Contain Match    ${resp}   *ClHolmes2*
    Should Contain Match    ${resp}   *ClTCA1*
    Should Contain Match    ${resp}   *ClTCA2*
    Should Not Contain Match    ${resp}   *ClHolmes99*
    Should Not Contain Match    ${resp}   *ClTCA99*
