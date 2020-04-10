## Common test scripts and env file for test

**test_env.sh**</br>
Common env variables for test in the auto-test dir. Used by the auto test cases/suites but could be used for other test script as well.

**testcase_common.sh**</br>
Common functions for auto test cases in the auto-test dir. A subset of the functions could be used in other test scripts as well.

**testsuite_common.sh**</br>
Common functions for auto test suites in the auto-test dir.

## Descriptions of functions in testcase_common.sh

The following is a list of the available functions in a test case file. Please see some of the defined test cases for examples.

**log_sim_settings**</br>
Print the env variables needed for the simulators and their setup

**clean_containers**</br>
Stop and remove all containers including dfc apps and simulators

**start_simulators**</br>
Start all simulators in the simulator group

**start_dfc <dfc-instance-id>**</br>
Start the dfc application. The arg shall be an integer from 0 to 5 representing the dfc instance to start. DFC app will get a name like 'dfc_app0' to 'dfc_app4'.

**kill_dfc  <dfc-instance-id> **</br>
Stop and remove the dfc app container with the instance id.

**consul_config_app <dfc-instance-id> <json-file-path>**</br>
Configure consul with json file with app config for a dfc instance using the dfc instance id and the json file.

**consul_config_dmaap <dfc-instance-id> <json-file-path>**</br>
Configure consul with json file with dmaap config for a dfc instance using the dfc instance id and the json file.

**kill_dr**</br>
Stop and remove the DR simulator container

**kill_drr**</br>
Stop and remove the DR redir simulator container

**kill_mr**</br>
Stop and remove the MR simulator container

**kill_sftp <sftp-instance-id>**</br>
Stop and remove a SFTP container with the supplied instance id (0-5).

**stop_sftp <sftp-instance-id>**</br>
Stop a SFTP container with the supplied instance id (0-5).

**start_sftp <sftp-instance-id>**</br>
Start a previously stopped SFTP container with the supplied instance id (0-5).

**kill_ftps <ftps-instance-id>**</br>
Stop and remove a FTPS container with the supplied instance id (0-5).

**stop_ftps <ftps-instance-id>**</br>
Stop a FTPS container with the supplied instance id (0-5).

**start_ftps <ftps-instance-id>**</br>
Start a previously stopped FTPS container with the supplied instance id (0-5).

**mr_print <vaiable-name>**</br>
Print a variable value from the MR simulator.

**dr_print <vaiable-name>**</br>
Print a variable value from the DR simulator.

**drr_print <vaiable-name>**</br>
Print a variable value from the DR redir simulator.

**dfc_print <dfc-instance-id> <vaiable-name>**</br>
Print a variable value from an dfc instance with the supplied instance id (0-5).

**mr_read <vaiable-name>**</br>
Read a variable value from MR sim and send to stdout

**dr_read <vaiable-name>**</br>
Read a variable value from DR sim and send to stdout

**drr_read <vaiable-name>**</br>
Read a variable value from DR redir sim and send to stdout

**sleep_wait <sleep-time-in-sec>**</br>
Sleep for a number of seconds

**sleep_heartbeat <sleep-time-in-sec>**</br>
Sleep for a number of seconds and prints dfc heartbeat output every 30 sec

**mr_equal <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the MR simulator is equal to a target value and an optional timeout.
</br>Arg: `<variable-name> <target-value>` - This test set pass or fail depending on if the variable is
equal to the targer or not.
</br>Arg: `<variable-name> <target-value> <timeout-in-sec>`  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value becomes equal to the target
value or not.

**mr_greater <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the MR simulator is greater than a target value and an optional timeout.
</br>Arg: `<variable-name> <target-value>` - This test set pass or fail depending on if the variable is
greater the target or not.
</br>Arg: `<variable-name> <target-value> <timeout-in-sec>`  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value is greater than the target
value or not.

**mr_less <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the MR simulator is less than a target value and an optional timeout.
</br>Arg: `<variable-name> <target-value>` - This test set pass or fail depending on if the variable is
less than the target or not.
</br>Arg: `<variable-name> <target-value> <timeout-in-sec>`  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value is less than the target
value or not.

**mr_contain_str <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the MR simulator contains a substring target and an optional timeout.
</br>Arg: `<variable-name> <target-value>` - This test set pass or fail depending on if the variable contains
the target substring or not.
</br>Arg: `<variable-name> <target-value> <timeout-in-sec>`  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value contains the target
substring or not.

**dr_equal <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the DR simulator is equal to a target value and an optional timeout.
</br>Arg: `<variable-name> <target-value>` - This test set pass or fail depending on if the variable is
equal to the target or not.
</br>Arg: `<variable-name> <target-value> <timeout-in-sec>`  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value becomes equal to the target
value or not.

**dr_greater <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the DR simulator is greater than a target value and an optional timeout.
</br>Arg: `<variable-name> <target-value>` - This test set pass or fail depending on if the variable is
greater the target or not.
</br>Arg: `<variable-name> <target-value> <timeout-in-sec>`  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value is greater than the target
value or not.

**dr_less <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the DR simulator is less than a target value and an optional timeout.
</br>Arg: `<variable-name> <target-value>` - This test set pass or fail depending on if the variable is
less than the target or not.
</br>Arg: `<variable-name> <target-value> <timeout-in-sec>`  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value is less than the target
value or not.

**dr_contain_str <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the DR simulator contains a substring target and an optional timeout.
</br>Arg: `<variable-name> <target-value>` - This test set pass or fail depending on if the variable contains
the target substring or not.
</br>Arg: `<variable-name> <target-value> <timeout-in-sec>`  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value contains the target
substring or not.

**drr_equal <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the DR Redir simulator is equal to a target value and an optional timeout.
</br>Arg: `<variable-name> <target-value>` - This test set pass or fail depending on if the variable is
equal to the target or not.
</br>Arg: `<variable-name> <target-value> <timeout-in-sec>`  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value becomes equal to the target
value or not.

**drr_greater <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the DR Redir simulator is greater than a target value and an optional timeout.
</br>Arg: `<variable-name> <target-value>` - This test set pass or fail depending on if the variable is
greater the target or not.
</br>Arg: `<variable-name> <target-value> <timeout-in-sec>`  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value is greater than the target
value or not.

**drr_less <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the DR Redir simulator is less than a target value and an optional timeout.
</br>Arg: `<variable-name> <target-value>` - This test set pass or fail depending on if the variable is
less than the target or not.
</br>Arg: `<variable-name> <target-value> <timeout-in-sec>`  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value is less than the target
value or not.

**drr_contain_str <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the DR Redir simulator contains a substring target and an optional timeout.
</br>Arg: `<variable-name> <target-value>` - This test set pass or fail depending on if the variable contains
the target substring or not.
</br>Arg: `<variable-name> <target-value> <timeout-in-sec>`  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value contains the target
substring or not.

**dfc_contain_str <variable-name> <substring-in-quotes>**</br>
Test if a variable in the DFC contains a substring.

**store_logs <log-prefix>**</br>
Store all dfc app and simulators log to the test case log dir. All logs get a prefix to
separate logs stored at different steps in the test script.
If logs need to be stored in several locations, use different prefix to easily identify the location
when the logs where taken.

**check_dfc_log**</br>
Check the dfc application log for WARN and ERR messages and print the count.

**print_result**</br>
Print the test result. Only once at the very end of the script.

**print_all**</br>
Print all variables from the simulators and the dfc heartbeat.

In addition, comment in the file can be added using the normal comment sign in bash '#'.
Comments that shall be visible on the screen as well as in the test case log, use `echo "<msg>"`.

## Descriptions of functions in testsuite_common.sh

The following is a list of the available functions in a test suite file.  Please see a existing test suite for examples.

**suite_setup**</br>
Sets up the test suite and print out a heading.

**run_tc <tc-script> &lt;$1 from test suite script> &lt;$2 from test suite script>**</br>
Execute a test case with arg from test suite script

**suite_complete**</br>
Print out the overall result of the executed test cases.
