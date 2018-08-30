*** Settings ***
| Resource | common.robot

*** Test Cases ***
# Based on Robot test cases created by Dawn Zelinski (dz2438@att.com).
| Verify Home page and links
# Access Home page - All tests files use this as starting point
| | RefreshMainURL
# Verify the links
| | Page should contain link | Home
| | Page should contain link | MY VNFs
| | Page should contain link | Test
| | Page should contain link | About us
| | Page Should Not Contain | ${USER_ID}
# Verify MY VNFs link will will ask for user entry
| | Click Link | MY VNFs
| | Wait Until Element Is Visible | id=userId | ${LONGTIME}
| | Input Text | id=userId | ${USERID}
| | Click Button | Submit
| | Page Should Contain | ${USER_ID}
| Verify Logout of user id
# Access Home page - All tests files use this as starting point
| | RefreshMainURL
| | Page Should Contain | ${USER_ID}
# Log out of user id and then see if My Vnfs asks for user entry
| | Click Element | id=more-button
# Line below also works.
#| | Click Element | xpath=(//*[@class='android-more-button mdl-button mdl-js-button mdl-button--primary'])
# Now Logout
| | Wait Until Element Is Visible | xpath=(//*[@class='mdl-menu__item mdl-js-ripple-effect']) | ${LONGTIME}
| | Click Element | xpath=(//*[@class='mdl-menu__item mdl-js-ripple-effect'])
| | Page Should Not Contain | ${USER_ID}
# Verify MY VNFs link will will ask for user entry
| | Click Link | MY VNFs
| | Wait Until Element Is Visible | id=userId | ${LONGTIME}
| | Input Text | id=userId | ${USERID}
| | Click Button | Submit
| | Page Should Contain | ${USER_ID}

| Test Uploading an existing VNF Reference file that was previously downloaded
# Access Home page - All tests files use this as starting point
| | RefreshMainURL
| | Click Link | MY VNFs
# Verify button element is ready before clicking it.
| | Wait Until Page Contains Element | xpath=(//*[@class='mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary']) | ${LONGTIME}
#| | Click Button | Create New VNF Type or VNFC Type
| | Click Button | Create New VNF Type
#| | Page Should Contain | Enter VNF type and VNFC to proceed
| | Page Should Contain | Enter VNF Type
| | Page Should Contain Element | id=vnfType
# Proceed without entering any new information
#| | Click Button | Proceed anyway
| | Click Button | Proceed To Upload
| | Page Should Contain Element | id=cmbAction
| | Click Button | Upload Reference File
| | Choose File | id=inputFile |  ${CURDIR}/data/reference_AllAction_HealthCheckAnsible_0.0.1V.json
| | Sleep | ${SHORTTIME}
# Verify the screen is populated with the HealthCheck (action), dawnMay17 (VNF Type and ANSIBLE (device protocol)
| | ${theVNFType} | Get Value | id=txtVnfType
| | ${theAction} | Get Selected List Value | id=cmbAction
| | ${theProtocol} | Get Selected List Value | id=txtDeviceProtocol
| | Should Be Equal As Strings | ${theVNFType} | csit
| | Should Be Equal As Strings | ${theAction} | HealthCheck
| | Should Be Equal As Strings | ${theProtocol} | ANSIBLE

| Test Creation of VNF
# Access Home page - All tests files use this as starting point
| | RefreshMainURL
| | Click Link | MY VNFs
# Verify button element is ready before clicking it.
| | Wait Until Page Contains Element | xpath=(//*[@class='mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary']) | ${LONGTIME}
#| | Click Button | Create New VNF Type or VNFC Type
| | Click Button | Create New VNF Type
#| | Page Should Contain | Enter VNF type and VNFC to proceed
| | Page Should Contain | Enter VNF Type
| | Page Should Contain Element | id=vnfType
# Create a date to use in VNF Type to make it unique
| | ${THEDATE}  | Get Current Date | result_format=%m%d%H%M%S | exclude_millis=True
| | Input Text | id=vnfType | csit${THEDATE}
| | Click Button | Next
| | Page Should Contain Element | id=cmbAction
# Verify 17 selections available
| | Select From List By Index | id=cmbAction | 17
# Select HealthCheck and ANSIBLE and verify it gets created
| | Select From List By Value | id=cmbAction | HealthCheck
| | Select From List By Value | id=txtDeviceProtocol | ANSIBLE
| | Click Button | saveToAppc
| | Sleep | ${SHORTTIME}
#| | Wait Until Page Contains | successfully uploaded the Reference Data | ${LONGTIME}
| | Click Link | MY VNFs
| | Page Should Contain | csit${THEDATE}

| Test Creation of VNF with multiple VNFCs
# This test is based on the 1806 Releases,
# APPC-C Design Tool User Guide for Self-Service Onboarding (section 5.1)
# Access Home page - All tests files use this as starting point
| | RefreshMainURL
| | Click Link | MY VNFs
# Verify button element is ready before clicking it.
| | Wait Until Page Contains Element | xpath=(//*[@class='mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary']) | ${LONGTIME}
#| | Click Button | Create New VNF Type or VNFC Type
| | Click Button | Create New VNF Type
| | Wait Until Page Contains Element | id=vnfType | ${LONGTIME}
# Create a date to use in VNF Type to make it unique
| | ${THEDATE}  | Get Current Date | result_format=%m%d%H%M%S | exclude_millis=True
| | Input Text | id=vnfType | csit${THEDATE}
| | Click Button | Next
| | Wait Until Page Contains Element | id=cmbAction | ${LONGTIME}
# Populate the action and protocol
| | Select From List By Value | id=cmbAction | Configure
| | Select From List By Value | id=txtDeviceProtocol | NETCONF-XML
# Populate the other VNF descriptors
| | Select From List By Value | name=template | Y
| | Input Text | name=loginUserName | ${USER_ID}
| | Input Text | name=portNumber | 777
# Describe the first VNFC Type and enter the number of VMs for this VNFC Type
| | Input Text | name=samplevnfcType | VNFC_type_A
| | Input Text | name=samplevnfcFunctionCode | aaa
| | Select From List By Value | name=sampleIpaddress | Y
| | Select From List By Value | name=sampleGroupNotation | first-vnfc-name
| | Input Text | name=sampleGroupValue | pair
| | Input Text | name=txtNumber23 | 2
| | Click Button | Add VM Information
| | Wait Until Page Contains | VM Number: 2 | ${LONGTIME}
# Clear information about the first VNFC
| | Click Button | Clear VNFC Info
# Describe the second VNFC Type and enter the number of VMs for this VNFC Type
| | Input Text | name=samplevnfcType | VNFC_type_B
| | Input Text | name=samplevnfcFunctionCode | bbb
| | Select From List By Value | name=sampleIpaddress | Y
| | Select From List By Value | name=sampleGroupNotation | first-vnfc-name
| | Input Text | name=sampleGroupValue | pair
| | Input Text | name=txtNumber23 | 2
| | Click Button | Add VM Information
| | Wait Until Page Contains | VM Number: 4 | ${LONGTIME}
| | Click Button | saveToAppc
| | Sleep | ${SHORTTIME}
#| | Wait Until Page Contains | successfully uploaded the Reference Data | ${LONGTIME}
| | Click Link | MY VNFs
| | Wait Until Page Contains | ARTIFACT NAME | ${LONGTIME}
| | Page Should Contain | csit${THEDATE}

| Test Creation of VNF with VNFC box checked
# This test is based on the 1806 Releases,
# APPC-C Design Tool User Guide for Self-Service Onboarding (section 5.1)
# Access Home page - All tests files use this as starting point
| | RefreshMainURL
| | Click Link | MY VNFs
# Verify button element is ready before clicking it.
| | Wait Until Page Contains Element | xpath=(//*[@class='mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--primary']) | ${LONGTIME}
#| | Click Button | Create New VNF Type or VNFC Type
| | Click Button | Create New VNF Type
| | Wait Until Page Contains Element | id=vnfType | ${LONGTIME}
# Create a date to use in VNF Type to make it unique
| | ${THEDATE}  | Get Current Date | result_format=%m%d%H%M%S | exclude_millis=True
| | Input Text | id=vnfType | csit${THEDATE}
# Check the box indicating VNFC templates
| | Select Checkbox | id=vnfcRequired
#| | Input Text | id=vnfcType | csitVNFC
| | Click Button | Next
| | Wait Until Page Contains Element | id=cmbAction | ${LONGTIME}
# Populate the action and protocol
| | Select From List By Value | id=cmbAction | Configure
| | Select From List By Value | id=txtDeviceProtocol | NETCONF-XML
# Populate the other VNF descriptors
| | Select From List By Value | name=template | Y
| | Input Text | name=loginUserName | ${USER_ID}
| | Input Text | name=portNumber | 777
# Describe the first VNFC Type and enter the number of VMs for this VNFC Type
| | Input Text | name=samplevnfcType | csitVNFC
| | Input Text | name=samplevnfcFunctionCode | aaa
| | Select From List By Value | name=sampleIpaddress | Y
| | Select From List By Value | name=sampleGroupNotation | first-vnfc-name
| | Input Text | name=sampleGroupValue | pair
| | Input Text | name=txtNumber23 | 2
| | Click Button | Add VM Information
| | Wait Until Page Contains | VM Number: 2 | ${LONGTIME}
# Clear information about the first VNFC
| | Click Button | Clear VNFC Info
# Describe the second VNFC Type and enter the number of VMs for this VNFC Type
| | Input Text | name=samplevnfcType | csitVNFC
| | Input Text | name=samplevnfcFunctionCode | bbb
| | Select From List By Value | name=sampleIpaddress | Y
| | Select From List By Value | name=sampleGroupNotation | first-vnfc-name
| | Input Text | name=sampleGroupValue | pair
| | Input Text | name=txtNumber23 | 2
| | Click Button | Add VM Information
| | Wait Until Page Contains | VM Number: 4 | ${LONGTIME}
| | Click Button | saveToAppc
| | Sleep | ${SHORTTIME}
| | Click Link | MY VNFs
| | Wait Until Page Contains | ARTIFACT NAME | ${LONGTIME}
| | Page Should Contain | csit${THEDATE}

