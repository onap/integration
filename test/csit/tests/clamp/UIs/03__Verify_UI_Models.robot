*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Variables ***
${login}                     admin
${passw}                     password

*** Test Cases ***
Verify HolmesModel1
    ${auth}=    Create List     ${login}    ${passw}
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${resp}=    Get Request    clamp   /restservices/clds/v1/clds/model/HolmesModel1
    Should Contain Match    ${resp}   *templateHolmes1*
    Should Contain Match    ${resp}   *DC2*
    Should Contain Match    ${resp}   *DC3*
    Should Contain Match    ${resp}   *Policy1*
    Should Contain Match    ${resp}   *07e266fc-49ab-4cd7-8378-ca4676f1b9ec*
    Should Contain Match    ${resp}   *migrate*
    Should Contain Match    ${resp}   *240*
    Should Contain Match    ${resp}   *390*
    Should Contain Match    ${resp}   *Logic1*
    Should Contain Match    ${resp}   *config Policy Name1*

Verify TCAModel1
    ${auth}=    Create List     ${login}    ${passw}
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${resp}=    Get Request    clamp   /restservices/clds/v1/clds/model/TCAModel1
    Should Contain Match    ${resp}   *templateTCA1*
    Should Contain Match    ${resp}   *c95b0e7c-c1f0-4287-9928-7964c5377a46*
    Should Contain Match    ${resp}   *vnfRecipe*
    Should Contain Match    ${resp}   *DC1*
    Should Contain Match    ${resp}   *DC3*
    Should Contain Match    ${resp}   *Policy2*
    Should Contain Match    ${resp}   *restart*
    Should Contain Match    ${resp}   *280*
    Should Contain Match    ${resp}   *400*

Get model names
    ${auth}=    Create List     ${login}    ${passw}
    Create Session   clamp  http://localhost:8080   auth=${auth}
    ${resp}=    Get Request    clamp   /restservices/clds/v1/clds/model-names
    Should Contain Match    ${resp}   *HolmesModel1*
    Should Contain Match    ${resp}   *TCAModel1*
    Should Not Contain Match    ${resp}   *TCAModel99*
    Should Not Contain Match    ${resp}   *HolmesModel99*
