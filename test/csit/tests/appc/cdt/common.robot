# CDT Regression Testing # Set the MAINURL via the command line
# run as:  
# 1) execute a .profile that sets and exports DEV2 and DEV4
# 2) robot --variable MAINURL:$DEV# filename.robot


*** Variables ***

#  ${MAINURL} is now set from the command line per above
|  ${BROWSER}  |  chrome
|  ${SHORTTIME} | 5s
|  ${LONGTIME} | 90s
|  ${TENMINUTES} | 600s
#|  ${FFPROFILE_DIR} |  /home/dvz/.mozilla/firefox/s87c07vn.AppCZoomed50
|  ${MAINURL} | http://localhost:8080/index.html
|  ${USER_ID} | csituser

*** Keywords ***
|  Setup1  | Open browser | ${MAINURL} | ${BROWSER} | | | | |
|  Setup2  | SLEEP | 2s

# Refresh the ${MAINURL} which is used as starting point within each test file
| RefreshMainURL
| | Go To | ${MAINURL}
| | Wait Until Page Contains | WELCOME TO CONTROLLER DESIGN TOOL | ${LONGTIME}


# Make sure you can get to APPC server - Wrap in implicit wait then reset
# Want to wait a few seconds to see if Server error appears. 
# Can't add an explicit wait to "Page should not contain"
| CheckForServerError 
| | [Arguments] | ${WAITTIME} 
| | Set Selenium Implicit Wait  | ${WAITTIME} 
| | Page Should Not Contain | Error in connecting to APPC Server
| | Set Selenium Implicit Wait  | 0


| ClickButtonByContent
| | [Arguments] |  ${TEXT}
| | ${RETVAL} | Execute Javascript | function clickButtonByTextContent(buttontext) { var buttons = document.querySelectorAll('button'); for (var i=0, l=buttons.length; i<l; i++) { if (buttons[i].firstChild.nodeValue == buttontext) { buttons[i].click(); return 0 } } return 1 }; var retval=clickButtonByTextContent('${TEXT}'); return retval;
| | Return From Keyword | ${RETVAL}

| ClickButtonByClassName
| | [Arguments] |  ${TEXT}
| | ${RETVAL} | Execute Javascript | function clickButtonByClassName(theclass) { var buttons = document.querySelectorAll('button'); for (var i=0, l=buttons.length; i<l; i++) { if (buttons[i].firstChild.nodeValue == theclass) { buttons[i].click(); return 0 } } return 1 }; var retval=clickButtonByClassName(${TEXT}); return retval;
| | Return From Keyword | ${RETVAL}

| EnterElementByClassName
| | [Arguments] |  ${THECLASS} | ${INPUTVALUE}
| | ${RETVAL} | Execute Javascript | function enterElementByClassName(theclass,theinput) { var element  = document.querySelector('.'+theclass).value = theinput; return 0 }; var retval=enterElementByClassName(${THECLASS},${INPUTVALUE}); return retval;
| | Return From Keyword | ${RETVAL}

*** Settings ***

|  Library  |  ExtendedSelenium2Library
|  Library  |  OperatingSystem
#|  Library  |  Dialogs
|  Library  |  DateTime


