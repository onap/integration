*** Settings ***
Documentation        store all properties that can change or are used in multiple places here
...                    format is all caps with underscores between words and prepended with GLOBAL
...                   make sure you prepend them with GLOBAL so that other files can easily see it is from this file.


*** Variables ***
${GLOBAL_VNF_RESTART_REQUESTFILE}    ../integration/test/csit/tests/appc/Resources/LCM_VN_RESTART_REQUEST.txt
${GLOBAL_VM_RESTART_REQUESTFILE}    ../integration/test/csit/tests/appc/Resources/LCM_VM_RESTART_REQUEST.txt
${GLOBAL_HEALTHCHECK_REQUESTFILE}    ../integration/test/csit/tests/appc/Resources/LCM_VM_HEALTHCHECK_REQUEST.txt