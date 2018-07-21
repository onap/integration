# This does setup and tear down of the suite

# NOTE 1: The subdirectories must include a symbolic link to this file
#         in order to run an individual .robot file (as compared to directory)
# NOTE 2: The Resource file must also be included in the test case .robot files

*** Settings ***

# Include a file of common variables, keywords and other settings
| Resource | common.robot

#| Suite Setup  | Run Keywords |  Setup1 | Setup2
| Suite Setup  | Run Keywords |  Setup2 | Setup1
| Suite Teardown | Close all browsers

