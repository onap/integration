## Running automated test case and test suites
Test cases run a single test case and test suites run one or more test cases in a sequence.

##Overall structure and setup
Test cases and test suites are written as bash scripts which call predefined functions in two other bash scripts
located in ../common dir.
The functions are described further below.
The integration repo is needed as well as docker.
If needed setup the ``DFC_LOCAL_IMAGE`` and ``DFC_REMOTE_IMAGE`` env var in test_env.sh to point to the dfc images (local registry image or next registry image) without the image tag.
The predefined images should be ok for current usage:
``DFC_REMOTE_IMAGE=nexus3.onap.org:10001/onap/org.onap.dcaegen2.collectors.datafile.datafile-app-server``
``DFC_LOCAL_IMAGE=onap/org.onap.dcaegen2.collectors.datafile.datafile-app-server``

If the test cases/suites in this dir are not executed in the auto-test dir in the integration repo, then the ``SIM_GROUP`` env var need to point to the ``simulator-group`` dir. 
See instructions in the test_env.sh. The ../common dir is needed as well in the case. That is, it is possible to have auto-test dir (and the common dir) somewhere 
than in the integration repo but the simulator group dir need to be available.

##Test cases and test suites naming.
Each file filename should have the format ``<tc-id>.sh`` for test cases and ``<ts-id>.sh`` for test suite. The tc-id and ts-id are the
identify of the test case or test suite. Example FTC2.sh, FTC2 is the id of the test case. Just the contents of the files determines if 
it is a test case or test suite so good to name the file so it is easy to see if it is a test case or a test suite.
A simple way to list all test cases/suite along with the description is to do ``grep ONELINE_DESCR *.sh`` in the shell.

##Logs from containers and test cases
All logs from each test cases are stored under ``logs/<tc-id>/``.
The logs include the application.log and the container log from dfc, the container logs from each simulator and the test case log (same as the screen output).

##Execution##
Test cases and test suites are executed by: ``./<tc-id or ts-id>.sh local | remote | remote-remove | manual-container | manual-app``</br>
**local** - uses the dfc image pointed out by ``DFC_LOCAL_IMAGE`` in the test_env, should be the dfc image built locally in your docker registry.</br>
**remote** - uses the dfc image pointed out by ``DFC_REMOTE_IMAGE`` in the test_env, should be the dfc nexus image in your docker registry.</br>
**remote-remove** - uses the dfc image pointed out by ``DFC_REMOTE_IMAGE`` in the test_env, should be the dfc nexus image in your docker registry. Removes the nexus image and pull from remote registry.</br>
**manual-container** - uses dfc in a manually started container. The script will prompt you for manual starting and stopping of the container.</br>
**manual-app** - uses dfc app started as an external process (from eclipse etc). The script will prompt you for manual start and stop of the process.</br>

##Test case file##
A test case file contains a number of steps to verify a certain functionality.
A description of the test case should be given to the ``TC_ONELINE_DESCR`` var. The description will be printed in the test result.

The empty template for a test case files looks like this:

(Only the parts noted with < and > shall be changed.)

-----------------------------------------------------------
```
#!/bin/bash

TC_ONELINE_DESCR="<test case description>"

. ../common/testcase_common.sh $1 $2

#### TEST BEGIN ####


<tests here>


#### TEST COMPLETE ####

store_logs          END

print_result

```
-----------------------------------------------------------

The ../common/testcase_common.sh contains all functions needed for the test case file.

The following is a list of the available functions in a test case file. Please see some of the defined test case for examples.

**log_sim_settings**</br>
Print the env variables needed for the simulators and their setup

**clean_containers**</br>
Stop and remove all containers including dfc app and simulators

**start_simulators**
Start all simulators in the simulator group

**start_dfc**</br>
Start the dfc application

**kill_dfc**</br>
Stop and remove the dfc app container

**kill_dr**</br>
Stop and remove the DR simulator container

**kill_drr**</br>
Stop and remove the DR redir simulator container

**kill_mr**</br>
Stop and remove the MR simulator container

**kill_sftp**</br>
Stop and remove the SFTP container

**kill_ftps**</br>
Stop and remove the FTPS container

**mr_print <vaiable-name>**</br>
Print a variable value from the MR simulator.

**dr_print <vaiable-name>**</br>
Print a varialle value from the DR simulator.

**drr_print <vaiable-name>**</br>
Print a variable value from the DR redir simulator.

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
Tests if a variable value in the MR simulator is equal to a target value and and optional timeout.
</br>Arg: ``<variable-name> <target-value>`` - This test set pass or fail depending on if the variable is
equal to the targer or not.
</br>Arg: ``<variable-name> <target-value> <timeout-in-sec>``  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value becomes equal to the target
value or not.

**mr_greater <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the MR simulator is greater than a target value and and optional timeout.
</br>Arg: ``<variable-name> <target-value>`` - This test set pass or fail depending on if the variable is
greater the target or not.
</br>Arg: ``<variable-name> <target-value> <timeout-in-sec>``  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value is greater than the target
value or not.

**mr_less <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the MR simulator is less than a target value and and optional timeout.
</br>Arg: ``<variable-name> <target-value>`` - This test set pass or fail depending on if the variable is
less than the target or not.
</br>Arg: ``<variable-name> <target-value> <timeout-in-sec>``  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value is less than the target
value or not.

**mr_contain_str <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the MR simulator contains a substring target and and optional timeout.
</br>Arg: ``<variable-name> <target-value>`` - This test set pass or fail depending on if the variable contains
the target substring or not.
</br>Arg: ``<variable-name> <target-value> <timeout-in-sec>``  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value contains the target
substring or not.

**dr_equal <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the DR simulator is equal to a target value and and optional timeout.
</br>Arg: ``<variable-name> <target-value>`` - This test set pass or fail depending on if the variable is
equal to the target or not.
</br>Arg: ``<variable-name> <target-value> <timeout-in-sec>``  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value becomes equal to the target
value or not.

**dr_greater <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the DR simulator is greater than a target value and and optional timeout.
</br>Arg: ``<variable-name> <target-value>`` - This test set pass or fail depending on if the variable is
greater the target or not.
</br>Arg: ``<variable-name> <target-value> <timeout-in-sec>``  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value is greater than the target
value or not.

**dr_less <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the DR simulator is less than a target value and and optional timeout.
</br>Arg: ``<variable-name> <target-value>`` - This test set pass or fail depending on if the variable is
less than the target or not.
</br>Arg: ``<variable-name> <target-value> <timeout-in-sec>``  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value is less than the target
value or not.

**drr_equal <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the DR Redir simulator is equal to a target value and and optional timeout.
</br>Arg: ``<variable-name> <target-value>`` - This test set pass or fail depending on if the variable is
equal to the target or not.
</br>Arg: ``<variable-name> <target-value> <timeout-in-sec>``  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value becomes equal to the target
value or not.

**drr_greater <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the DR Redir simulator is greater than a target value and and optional timeout.
</br>Arg: ``<variable-name> <target-value>`` - This test set pass or fail depending on if the variable is
greater the target or not.
</br>Arg: ``<variable-name> <target-value> <timeout-in-sec>``  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value is greater than the target
value or not.

**drr_less <variable-name> <target-value> [<timeout-in-sec>]**</br>
Tests if a variable value in the DR Redir simulator is less than a target value and and optional timeout.
</br>Arg: ``<variable-name> <target-value>`` - This test set pass or fail depending on if the variable is
less than the target or not.
</br>Arg: ``<variable-name> <target-value> <timeout-in-sec>``  - This test waits up to the timeout seconds
before setting pass or fail depending on if the variable value is less than the target
value or not.

**dfc_contain_str <variable-name> <substring-in-quotes>**</br>
Test is a variable in the DFC contains a substring.

**store_logs <log-prefix>**</br>
Store all dfc app and simulators log to the test case log dir. All logs gets a prefix to
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
Comments that shall be visible on the screen as well as in the test case log, use ``echo "<msg>"``.

##Test suite files##
A test suite file contains one or more test cases to run in sequence.
A description of the test case should be given to the TS_ONELINE_DESCR var. The description will be printed in the test result.

The empty template for a test suite files looks like this:

(Only the parts noted with ``<`` and ``>`` shall be changed.)

-----------------------------------------------------------
```
#!/bin/bash

TS_ONELINE_DESCR="<test-suite-description"

. ../common/testsuite_common.sh

suite_setup

############# TEST CASES #################

run_tc <tc-id or ts-id>.sh $1 $2
...
...

##########################################

suite_complete


```
-----------------------------------------------------------

The ../common/testsuite_common.sh contains all functions needed for a test suite file.

The following is a list of the available functions in a test case file. Please see a defined test suite for examples.

**suite_setup**</br>
Sets up the test suite and print out a heading.

**run_tc <tc-script> <$1 from test suite script> <$2 from test suite script>**</br>
Execute a test case with arg from test suite script

**suite_complete**</br>
Print out the overall result of the executed test cases.