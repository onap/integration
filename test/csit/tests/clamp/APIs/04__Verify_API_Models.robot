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
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/clds/model/ClHolmes1
    Should Contain Match    ${resp}   *templateHolmes1*
    Should Contain Match    ${resp}   *DC1*
    Should Contain Match    ${resp}   *DC2*
    Should Contain Match    ${resp}   *Policy1*
    Should Contain Match    ${resp}   *vnfRecipe*
    Should Contain Match    ${resp}   *180*
    Should Contain Match    ${resp}   *345*
    Should Contain Match    ${resp}   *Config Policy name1*

Verify HolmesModel2
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/clds/model/ClHolmes2
    Should Contain Match    ${resp}   *templateHolmes2*
    Should Contain Match    ${resp}   *DC2*
    Should Contain Match    ${resp}   *DC3*
    Should Contain Match    ${resp}   *Policy2*
    Should Contain Match    ${resp}   *vnfRecipe*
    Should Contain Match    ${resp}   *migrate*
    Should Contain Match    ${resp}   *360*
    Should Contain Match    ${resp}   *345*
    Should Contain Match    ${resp}   *Config Policy Name2*

Verify TCAModel1
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/clds/model/ClTCA1
    Should Contain Match    ${resp}   *templateTCA1*
    Should Contain Match    ${resp}   *enbRecipe*
    Should Contain Match    ${resp}   *DC1*
    Should Contain Match    ${resp}   *DC2*
    Should Contain Match    ${resp}   *Policy3*
    Should Contain Match    ${resp}   *345*
    Should Contain Match    ${resp}   *200*
    Should Contain Match    ${resp}   *ONSET*

Verify TCAModel2
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/clds/model/ClTCA2
    Should Contain Match    ${resp}   *templateTCA2*
    Should Contain Match    ${resp}   *enbRecipe*
    Should Contain Match    ${resp}   *DC1*
    Should Contain Match    ${resp}   *DC2*
    Should Contain Match    ${resp}   *DC3*
    Should Contain Match    ${resp}   *Policy4*
    Should Contain Match    ${resp}   *tcaPol*
    Should Contain Match    ${resp}   *345*
    Should Contain Match    ${resp}   *300*
    Should Contain Match    ${resp}   *VM*

Get model names
    ${resp}=    Get Request    ${clamp_session}   /restservices/clds/v1/clds/model-names
    Should Contain Match    ${resp}   *ClHolmes1*
    Should Contain Match    ${resp}   *ClHolmes2*
    Should Contain Match    ${resp}   *ClTCA1*
    Should Contain Match    ${resp}   *ClTCA2*
    Should Not Contain Match    ${resp}   *ClTCA99*
    Should Not Contain Match    ${resp}   *ClHolmes99*

