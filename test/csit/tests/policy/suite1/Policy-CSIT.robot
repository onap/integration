*** Settings ***
Documentation	  Policy ONAP CSIT Test cases
Library    String
Library    HttpLibrary.HTTP
LIbrary    Process
Resource    policy_interface.robot
Resource    json_templater.robot

*** Variables ***
${RESOURCE_PATH_CREATE}        /pdp/api/createPolicy
${RESOURCE_PATH_CREATE_PUSH}        /pdp/api/pushPolicy
${RESOURCE_PATH_CREATE_DELETE}        /pdp/api/deletePolicy
${RESOURCE_PATH_GET_CONFIG}    /pdp/api/getConfig
${CREATE_CONFIG_VFW_TEMPLATE}    ${CURDIR}/configpolicy_vFW.template
${CREATE_CONFIG_VDNS_TEMPLATE}    ${CURDIR}/configpolicy_vDNS.template
${CREATE_CONFIG_VCPE_TEMPLATE}    ${CURDIR}/configpolicy_vCPE.template
${CREATE_OPS_VFW_TEMPLATE}    ${CURDIR}/opspolicy_VFW_R1.template
${PUSH_POLICY_TEMPLATE}   ${CURDIR}/pushpolicy.template
${CREATE_OPS_VDNS_TEMPLATE}    ${CURDIR}/opspolicy_VDNS_R1.template
${DEL_POLICY_TEMPLATE}   ${CURDIR}/deletepolicy.template
${GETCONFIG_TEMPLATE}    ${CURDIR}/getconfigpolicy.template
${CONFIG_POLICY_VFW_NAME}    vFirewall
${CONFIG_POLICY_VFW_TYPE}    MicroService
${CONFIG_POLICY_VDNS_NAME}    vLoadBalancer
${CONFIG_POLICY_VDNS_TYPE}    MicroService
${OPS_POLICY_VFW_NAME}    vFirewall
${OPS_POLICY_VFW_TYPE}    BRMS_PARAM
${OPS_POLICY_VDNS_NAME}    vLoadBalancer
${OPS_POLICY_VDNS_TYPE}    BRMS_PARAM
${CONFIG_POLICY_VCPE_NAME}    vCPE
${CONFIG_POLICY_VCPE_TYPE}    MicroService
${OPS_POLICY_VCPE_NAME}    vCPE
${OPS_POLICY_VCPE_TYPE}    BRMS_PARAM
${OPS_POLICY_VOLTE_NAME}    VoLTE
${OPS_POLICY_VOLTE_TYPE}    BRMS_PARAM
${file_path}        ../testsuite/robot/assets/templates/ControlLoopDemo__closedLoopControlName.drl
${RESOURCE_PATH_UPLOAD}  /pdp/api/policyEngineImport?importParametersJson=%7B%22serviceName%22%3A%22Manyu456%22%2C%20%22serviceType%22%3A%22BRMSPARAM%22%7D
${CREATE_OPS_VCPE_TEMPLATE}      ${CURDIR}/opspolicy_vCPE.template  
${CREATE_OPS_VOLTE_TEMPLATE}    ${CURDIR}/opspolicy_vOLTE.template


*** Test Cases ***
Policy Health check
    Run Policy Health Check

VFW Config Policy
    ${CONFIG_POLICY_VFW_NAME}=    Create Config VFW Policy
    Push Config Policy    ${CONFIG_POLICY_VFW_NAME}    ${CONFIG_POLICY_VFW_TYPE}
VFW Get Configs Policy
    Get Configs VFW Policy   
    #VFW Policy Tests
    
VDNS Config Policy
    ${CONFIG_POLICY_VDNS_NAME}=    Create Config VDNS Policy
    Push Config Policy    ${CONFIG_POLICY_VDNS_NAME}    ${CONFIG_POLICY_VDNS_TYPE}
    #VDNS Policy Tests
   
VCPE Config Policy
    ${CONFIG_POLICY_VCPE_NAME}=    Create Config VCPE Policy
    Push Config Policy    ${CONFIG_POLICY_VCPE_NAME}    ${CONFIG_POLICY_VCPE_TYPE}
    #VCPE Policy Tests
 
VFW Ops Policy
     ${OPS_POLICY_VFW_NAME}=    Create Ops VFW Policy
     Push Ops Policy    ${OPS_POLICY_VFW_NAME}    ${OPS_POLICY_VFW_TYPE}
     
VDNS Ops Policy
     ${OPS_POLICY_VDNS_NAME}=    Create Ops VDNS Policy
     Push Ops Policy    ${OPS_POLICY_VDNS_NAME}    ${OPS_POLICY_VDNS_TYPE}    
     
VCPE Ops Policy
     ${OPS_POLICY_VCPE_NAME}=    Create Ops VCPE Policy
     Push Ops Policy    ${OPS_POLICY_VCPE_NAME}    ${OPS_POLICY_VCPE_TYPE}    

VOLTE Ops Policy
     ${OPS_POLICY_VOLTE_NAME}=    Create Ops VOLTE Policy
     Push Ops Policy    ${OPS_POLICY_VOLTE_NAME}    ${OPS_POLICY_VOLTE_TYPE}    
    #VOLTE Policy Tests
    
*** Keywords ***

VFW Policy Tests
     ${CONFIG_POLICY_VFW_NAME}=    Create Config VFW Policy
     Push Config Policy    ${CONFIG_POLICY_VFW_NAME}    ${CONFIG_POLICY_VFW_TYPE}
     Get Configs VFW Policy    
     ${OPS_POLICY_VFW_NAME}=    Create Ops VFW Policy
     Push Ops Policy    ${OPS_POLICY_VFW_NAME}    ${OPS_POLICY_VFW_TYPE}
    
VDNS Policy Tests
     ${CONFIG_POLICY_VDNS_NAME}=    Create Config VDNS Policy
     Push Config Policy    ${CONFIG_POLICY_VDNS_NAME}    ${CONFIG_POLICY_VDNS_TYPE}
     Get Configs VDNS Policy
     ${OPS_POLICY_VDNS_NAME}=    Create Ops VDNS Policy
     Push Ops Policy    ${OPS_POLICY_VDNS_NAME}    ${OPS_POLICY_VDNS_TYPE}

VCPE Policy Tests
     ${CONFIG_POLICY_VCPE_NAME}=    Create Config VCPE Policy
     Push Config Policy    ${CONFIG_POLICY_VCPE_NAME}    ${CONFIG_POLICY_VCPE_TYPE}
     Get Configs VCPE Policy    
     ${OPS_POLICY_VCPE_NAME}=    Create Ops VCPE Policy
     Push Ops Policy    ${OPS_POLICY_VCPE_NAME}    ${OPS_POLICY_VCPE_TYPE}
     
VOLTE Policy Tests  
     ${OPS_POLICY_VOLTE_NAME}=    Create Ops VOLTE Policy
     Push Ops Policy    ${OPS_POLICY_VOLTE_NAME}    ${OPS_POLICY_VOLTE_TYPE}
     
Get Configs VFW Policy
    [Documentation]    Get Config Policy for VFW
    ${getconfigpolicy}=    Catenate    .*${CONFIG_POLICY_VFW_NAME}*
    ${configpolicy_name}=    Create Dictionary    config_policy_name=${getconfigpolicy}
    ${output} =     Fill JSON Template File     ${GETCONFIG_TEMPLATE}    ${configpolicy_name}
    ${get_resp} =    Run Policy Get Configs Request    ${RESOURCE_PATH_GET_CONFIG}   ${output}
	Should Be Equal As Strings 	${get_resp.status_code} 	200
	
Create Config VFW Policy
    [Documentation]    Create Config Policy
    ${randompolicyname} =     Create Policy Name
    ${policyname1}=    Catenate   com.${randompolicyname}_vFirewall
    ${CONFIG_POLICY_VFW_NAME}=    Set Test Variable    ${policyname1}
    ${configpolicy}=    Create Dictionary    policy_name=${policyname1}
    ${output} =     Fill JSON Template File     ${CREATE_CONFIG_VFW_TEMPLATE}    ${configpolicy}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
	Should Be Equal As Strings 	${put_resp.status_code} 	200
	[Return]    ${policyname1}

 Create Policy Name
     [Documentation]    Generate Policy Name
     [Arguments]    ${prefix}=CSIT_
     ${random}=    Generate Random String    15    [LOWER][NUMBERS]
     ${policyname}=    Catenate    ${prefix}${random}
     [Return]    ${policyname}

Create Ops VFW Policy
	[Documentation]    Create Opertional Policy
   	${randompolicyname} =     Create Policy Name
	${policyname1}=    Catenate   com.${randompolicyname}_vFirewall
	${OPS_POLICY_VFW_NAME}=    Set Test Variable    ${policyname1}
 	${dict}=     Create Dictionary    policy_name=${policyname1}
	${output} =     Fill JSON Template File     ${CREATE_OPS_VFW_TEMPLATE}    ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
    Log    ${put_resp}
    Should Be Equal As Strings 	${put_resp.status_code} 	200
    [Return]    ${policyname1}

Push Ops Policy
    [Documentation]    Push Ops Policy
    [Arguments]    ${policyname}    ${policytype}
    ${dict}=     Create Dictionary     policy_name=${policyname}    policy_type=${policytype}
	${output} =     Fill JSON Template File    ${PUSH_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE_PUSH}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Push Config Policy
    [Documentation]    Push Config Policy
    [Arguments]    ${policyname}    ${policytype}
    ${dict}=     Create Dictionary     policy_name=${policyname}    policy_type=${policytype}
	${output} =     Fill JSON Template File    ${PUSH_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE_PUSH}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Delete Ops Policy
    [Documentation]    Delete Config Policy
    [Arguments]    ${policy_name}
    ${policyname3}=    Catenate   com.Config_BRMS_Param_${policyname}.1.xml
    ${dict}=     Create Dictionary     policy_name=${policyname3}
	${output} =     Fill JSON Template     ${DEL_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Delete Request    ${RESOURCE_PATH_CREATE_DELETE}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Delete Config Policy
    [Documentation]    Delete Ops Policy
    [Arguments]    ${policy_name}
    ${policyname3}=    Catenate   com.Config_MS_com.${policy_name}.1.xml
    ${dict}=     Create Dictionary     policy_name=${policyname3}
	${output} =     Fill JSON Template     ${DEL_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Delete Request    ${RESOURCE_PATH_CREATE_DELETE}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Get Configs VDNS Policy
    [Documentation]    Get Config Policy for VDNS
    ${getconfigpolicy}=    Catenate    .*${CONFIG_POLICY_VDNS_NAME}*
    ${configpolicy_name}=    Create Dictionary    config_policy_name=${getconfigpolicy}
    ${output} =     Fill JSON Template File     ${GETCONFIG_TEMPLATE}    ${configpolicy_name}
    ${get_resp} =    Run Policy Get Configs Request    ${RESOURCE_PATH_GET_CONFIG}   ${output}
	Should Be Equal As Strings 	${get_resp.status_code} 	200
	
Create Config VDNS Policy
    [Documentation]    Create Config Policy
    ${randompolicyname} =     Create Policy Name
    ${policyname1}=    Catenate   com.${randompolicyname}_vLoadBalancer
    ${CONFIG_POLICY_VDNS_NAME}=    Set Test Variable    ${policyname1}
    ${configpolicy}=    Create Dictionary    policy_name=${policyname1}
    ${output} =     Fill JSON Template File     ${CREATE_CONFIG_VDNS_TEMPLATE}    ${configpolicy}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
	Should Be Equal As Strings 	${put_resp.status_code} 	200
	[Return]    ${policyname1}

Create Ops VDNS Policy
	[Documentation]    Create Opertional Policy
   	${randompolicyname} =     Create Policy Name
	${policyname1}=    Catenate   com.${randompolicyname}_vLoadBalancer
	${OPS_POLICY_VDNS_NAME}=    Set Test Variable    ${policyname1}
 	${dict}=     Create Dictionary    policy_name=${policyname1}
	${output} =     Fill JSON Template File     ${CREATE_OPS_VDNS_TEMPLATE}    ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
    Log    ${put_resp}
    Should Be Equal As Strings 	${put_resp.status_code} 	200
    [Return]    ${policyname1}
    
Create Config VCPE Policy
    [Documentation]    Create Config Policy
    ${randompolicyname} =     Create Policy Name
    ${policyname1}=    Catenate   com.${randompolicyname}_vFirewall
    ${CONFIG_POLICY_VCPE_NAME}=    Set Test Variable    ${policyname1}
    ${configpolicy}=    Create Dictionary    policy_name=${policyname1}
    ${output} =     Fill JSON Template File     ${CREATE_CONFIG_VCPE_TEMPLATE}    ${configpolicy}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
	Should Be Equal As Strings 	${put_resp.status_code} 	200
	[Return]    ${policyname1}
	
Get Configs VCPE Policy
    [Documentation]    Get Config Policy for VCPE
    ${getconfigpolicy}=    Catenate    .*${CONFIG_POLICY_VCPE_NAME}*
    ${configpolicy_name}=    Create Dictionary    config_policy_name=${getconfigpolicy}
    ${output} =     Fill JSON Template File     ${GETCONFIG_TEMPLATE}    ${configpolicy_name}
    ${get_resp} =    Run Policy Get Configs Request    ${RESOURCE_PATH_GET_CONFIG}   ${output}
	Should Be Equal As Strings 	${get_resp.status_code} 	200

Create Ops vCPE Policy
	[Documentation]    Create Opertional Policy
   	${randompolicyname} =     Create Policy Name
	${policyname1}=    Catenate   com.${randompolicyname}
	${OPS_POLICY_VCPE_NAME}=    Set Test Variable    ${policyname1}
 	${dict}=     Create Dictionary    policy_name=${policyname1}
	${output} =     Fill JSON Template File     ${CREATE_OPS_VCPE_TEMPLATE}    ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
    Log    ${put_resp}
    Should Be Equal As Strings 	${put_resp.status_code} 	200
    [Return]    ${policyname1}
    
Create Ops VolTE Policy
	[Documentation]    Create Opertional Policy
   	${randompolicyname} =     Create Policy Name
	${policyname1}=    Catenate   com.${randompolicyname}
 	${dict}=     Create Dictionary    policy_name=${policyname1}
	${output} =     Fill JSON Template File     ${CREATE_OPS_VOLTE_TEMPLATE}    ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
    Log    ${put_resp}
    Should Be Equal As Strings 	${put_resp.status_code} 	200
    [Return]    ${policyname1}
    
Upload DRL file
    [Documentation]    Upload DRL file1
    ${file_data}=     Get Binary File  ${file_path}
    ${files}=    Create Dictionary    file=${file_data}
   #${CONFIG_POLICY_VDNS_NAME}=    Set Test Variable    ${policyname1}
   # ${files2} = {'file': open('../testsuite/robot/assets/templates/ControlLoopDemo__closedLoopControlName.drl', 'rb')}
   # ${files}=  Create Dictionary  file  ${file_data}
    ${put_resp} =    Run Policy Post form Request    ${RESOURCE_PATH_UPLOAD}    ${files}      
	Should Be Equal As Strings 	${put_resp.status_code} 	200