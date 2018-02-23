*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json


*** Test Cases ***
Get Clamp properties
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${resp}=    Get Request    clamp   /restservices/clds/v1/clds/properties
    Dictionary Should Contain Key    ${resp.json()}   global
    Dictionary Should Contain Key    ${resp.json()['global']}   location

Get Clamp Info
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${resp}=    Get Request    clamp   /restservices/clds/v1/clds/cldsInfo
    Dictionary Should Contain Key    ${resp.json()}   userName
    Dictionary Should Contain Key    ${resp.json()}   cldsVersion

Get model bpmn by name
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${resp}=    Get Request    clamp   /restservices/clds/v1/clds/model/bpmn/ClHolmes1
    Should Contain Match    ${resp}   *StartEvent_*
    Should Contain Match    ${resp}   *VesCollector_*
    Should Contain Match    ${resp}   *Holmes_*
    Should Contain Match    ${resp}   *Policy_*
    Should Contain Match    ${resp}   *EndEvent_*

Get model by name
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${resp}=    Get Request    clamp   /restservices/clds/v1/clds/model/ClHolmes1
    Dictionary Should Contain Key    ${resp.json()}   templateName
    Dictionary Should Contain Key    ${resp.json()}   bpmnText
    Dictionary Should Contain Key    ${resp.json()}   imageText

Get model names
    ${auth}=    Create List     admin    5f4dcc3b5aa765d61d8327deb882cf99
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${resp}=    Get Request    clamp   /restservices/clds/v1/clds/model-names
    Should Contain Match    ${resp}   *ClHolmes1*
    Should Contain Match    ${resp}   *ClHolmes2*
    Should Contain Match    ${resp}   *ClTCA1*
    Should Contain Match    ${resp}   *ClTCA2*
    Should Not Contain Match    ${resp}   *ClHolmes99*
    Should Not Contain Match    ${resp}   *ClTCA99*
