*** Settings ***
Documentation	  Policy ONAP CSIT Test cases
Library    String
Library    HttpLibrary.HTTP
LIbrary    Process
Resource    policy_interface.robot

*** Variables ***
${RESOURCE_PATH_CREATE}        /pdp/createPolicy
${RESOURCE_PATH_CREATE_PUSH}        /pdp/pushPolicy
${RESOURCE_PATH_CREATE_DELETE}        /pdp/deletePolicy
${RESOURCE_PATH_GET_CONFIG}    /pdp/getConfig
${CREATE_CONFIG_VFW_TEMPLATE}    configpolicy_vFW.template
${CREATE_CONFIG_VDNS_TEMPLATE}    configpolicy_vDNS.template
${CREATE_OPS_VFW_TEMPLATE}    opspolicy_VFW.template
${PUSH_POLICY_VFW_TEMPLATE}   pushpolicy.template
${CREATE_OPS_VDNS_TEMPLATE}    opspolicy_VDNS.template
${PUSH_POLICY_VDNS_TEMPLATE}   pushpolicy.template
${DEL_POLICY_TEMPLATE}   deletepolicy.template
${GETCONFIG_TEMPLATE}    getconfigpolicy.template
${CONFIG_POLICY_VFW_NAME}    vFirewall
${CONFIG_POLICY_VFW_TYPE}    Unknown
${CONFIG_POLICY_VDNS_NAME}    vLoadBalancer
${CONFIG_POLICY_VDNS_TYPE}    Unknown
${OPS_POLICY_VFW_NAME}
${OPS_POLICY_VFW_TYPE}    BRMS_PARAM
${OPS_POLICY_VDNS_NAME}
${OPS_POLICY_VDNS_TYPE}    BRMS_PARAM

*** Test Cases ***
Policy Health check
    Run Policy Health Check
    
VFW Policy
    VFW Policy Tests
    
VDNS Policy
    VDNS Policy Tests
    
*** Keywords ***

VFW Policy Tests
    Get Configs VFW Policy
    Create Config VFW Policy
    Push Config Policy    ${CONFIG_POLICY_VFW_NAME}    ${CONFIG_POLICY_VFW_TYPE}
    Create Ops VFW Policy
    Push Ops Policy    ${OPS_POLICY_VFW_NAME}    ${OPS_POLICY_VFW_TYPE}
    
VDNS Policy Tests
    Get Configs VDNS Policy
    Create Config VDNS Policy
    Push Config Policy    ${CONFIG_POLICY_VDNS_NAME}    ${CONFIG_POLICY_VDNS_TYPE}
    Create Ops VDNS Policy
    Push Ops Policy    ${OPS_POLICY_VDNS_NAME}    ${OPS_POLICY_VDNS_TYPE}
    
Get Configs VFW Policy
    [Documentation]    Get Config Policy for VFW
    ${getconfigpolicy}=    Catenate    .*${CONFIG_POLICY_VFW_NAME}*
    ${configpolicy_name}=    Create Dictionary    CONFIG_POLICY_VFW_NAME=${getconfigpolicy}
    ${output} =     Fill JSON Template File     ${GETCONFIG_TEMPLATE}    ${configpolicy_name}
    ${get_resp} =    Run Policy Get Configs Request    ${RESOURCE_PATH_GET_CONFIG}   ${output}
	Should Be Equal As Strings 	${get_resp.status_code} 	200
	
Create Config VFW Policy
    [Documentation]    Create Config Policy
    ${randompolicyname} =     Create Policy Name
    ${policyname1}=    Catenate   com.${randompolicyname}
    ${CONFIG_POLICY_VFW_NAME}=    Set Test Variable    ${policyname1}
    ${configpolicy}=    Create Dictionary    policy_name=${CONFIG_POLICY_VFW_NAME}
    ${output} =     Fill JSON Template File     ${CREATE_CONFIG_VFW_TEMPLATE}    ${configpolicy}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
	Should Be Equal As Strings 	${put_resp.status_code} 	200

 Create Policy Name
     [Documentation]    Generate Policy Name
     [Arguments]    ${prefix}=CSIT_
     ${random}=    Generate Random String    15    [LOWER][NUMBERS]
     ${policyname}=    Catenate    ${prefix}${random}
     [Return]    ${policyname}

Create Ops VFW Policy
	[Documentation]    Create Opertional Policy
   	${randompolicyname} =     Create Policy Name
	${policyname1}=    Catenate   com.${randompolicyname}
	${OPS_POLICY_NAME}=    Set Test Variable    ${policyname1}
 	${dict}=     Create Dictionary    policy_name=${OPS_POLICY_NAME}
 	#${NEWPOLICY1}=     Create Dictionary    policy_name=com.${OPS_POLICY_NAME}
	${output} =     Fill JSON Template File     ${CREATE_OPS_VFW_TEMPLATE}    ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
    Log    ${put_resp}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Push Ops Policy
    [Documentation]    Push Ops Policy
    [Arguments]    ${policyname}    ${policytype}
    ${dict}=     Create Dictionary     policy_name=${policyname}    policy_type=${policytype}
	${output} =     Fill JSON Template     ${PUSH_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE_PUSH}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Push Config Policy
    [Documentation]    Push Config Policy
    [Arguments]    ${policyname}    ${policytype}
    ${dict}=     Create Dictionary     policy_name=${policyname}    policy_type=${policytype}
	${output} =     Fill JSON Template     ${PUSH_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE_PUSH}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200


Delete Config Policy
    [Documentation]    Delete Config Policy
    [Arguments]    ${policy_name}
    ${policyname3}=    Catenate   com.Config_BRMS_Param_${policyname}.1.xml
    ${dict}=     Create Dictionary     policy_name=${policyname3}
	${output} =     Fill JSON Template     ${DEL_POLICY_TEMPLATE}     ${dict}
    ${put_resp} =    Run Policy Delete Request    ${RESOURCE_PATH_CREATE_DELETE}  ${output}
    Should Be Equal As Strings 	${put_resp.status_code} 	200

Delete Ops Policy
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
    ${configpolicy_name}=    Create Dictionary    CONFIG_POLICY_VDNS_NAME=${getconfigpolicy}
    ${output} =     Fill JSON Template File     ${GETCONFIG_TEMPLATE}    ${configpolicy_name}
    ${get_resp} =    Run Policy Get Configs Request    ${RESOURCE_PATH_GET_CONFIG}   ${output}
	Should Be Equal As Strings 	${get_resp.status_code} 	200
	
Create Config VDNS Policy
    [Documentation]    Create Config Policy
    ${randompolicyname} =     Create Policy Name
    ${policyname1}=    Catenate   com.${randompolicyname}
    ${CONFIG_POLICY_VDNS_NAME}=    Set Test Variable    ${policyname1}
    ${configpolicy}=    Create Dictionary    policy_name=${CONFIG_POLICY_VDNS_NAME}
    ${output} =     Fill JSON Template File     ${CREATE_CONFIG_VDNS_TEMPLATE}    ${configpolicy}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
	Should Be Equal As Strings 	${put_resp.status_code} 	200

Create Ops VDNS Policy
	[Documentation]    Create Opertional Policy
   	${randompolicyname} =     Create Policy Name
	${policyname1}=    Catenate   com.${randompolicyname}
	${OPS_POLICY_VDNS_NAME}=    Set Test Variable    ${policyname1}
 	${dict}=     Create Dictionary    policy_name=${OPS_POLICY_VDNS_NAME}
 	#${NEWPOLICY1}=     Create Dictionary    policy_name=com.${OPS_POLICY_NAME}
	${output} =     Fill JSON Template File     ${CREATE_OPS_VDNS_TEMPLATE}    ${dict}
    ${put_resp} =    Run Policy Put Request    ${RESOURCE_PATH_CREATE}  ${output}
    Log    ${put_resp}
    Should Be Equal As Strings 	${put_resp.status_code} 	200