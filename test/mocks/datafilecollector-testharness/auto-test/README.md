# Running automated test case and test suites

Test cases run a single test case and test suites run one or more test cases in a sequence.

The test cases and test suites are possible to run on both Ubuntu and Mac-OS. 

## Overall structure and setup

Test cases and test suites are written as bash scripts which call predefined functions in two other bash scripts
located in ../common dir.
The functions are described further below.
The integration repo is needed as well as docker.
If needed setup the `DFC_LOCAL_IMAGE` and `DFC_REMOTE_IMAGE` env var in test_env.sh to point to the dfc images (local registry image or next registry image) without the image tag.
The predefined images should be ok for current usage:

`DFC_REMOTE_IMAGE=nexus3.onap.org:10001/onap/org.onap.dcaegen2.collectors.datafile.datafile-app-server`

`DFC_LOCAL_IMAGE=onap/org.onap.dcaegen2.collectors.datafile.datafile-app-server`

If the test cases/suites in this dir are not executed in the auto-test dir in the integration repo, then the `SIM_GROUP` env var need to point to the `simulator-group` dir. 
See instructions in the test_env.sh. The ../common dir is needed as well in the case. That is, it is possible to have auto-test dir (and the common dir) somewhere else
than in the integration repo but the simulator-group and common dir need to be available.

## Test cases and test suites naming

Each file filename should have the format `<tc-id>.sh` for test cases and `<ts-id>.sh` for test suite. The tc-id and ts-id are the
identify of the test case or test suite. Example FTC2.sh, FTC2 is the id of the test case. Just the contents of the files determines if 
it is a test case or test suite so good to name the file so it is easy to see if it is a test case or a test suite.
A simple way to list all test cases/suite along with the description is to do `grep ONELINE_DESCR *.sh` in the shell.

## Logs from containers and test cases

All logs from each test cases are stored under `logs/<tc-id>/`.
The logs include the application.log and the container log from dfc, the container logs from each simulator and the test case log (same as the screen output).
In the test cases the logs are stored with a prefix so the logs can be stored at different steps during the test. All test cases contains an entry to save all logs with prefix 'END' at the end of each test case.

## Execution

Test cases and test suites are executed by: ` [sudo] ./<tc-id or ts-id>.sh local | remote | remote-remove | manual-container | manual-app`</br>

- **local** - uses the dfc image pointed out by `DFC_LOCAL_IMAGE` in the test_env, should be the dfc image built locally in your docker registry.</br>
- **remote** - uses the dfc image pointed out by `DFC_REMOTE_IMAGE` in the test_env, should be the dfc nexus image in your docker registry.</br>
- **remote-remove** - uses the dfc image pointed out by `DFC_REMOTE_IMAGE` in the test_env, should be the dfc nexus image in your docker registry. Removes the nexus image and pull from remote registry.</br>
- **manual-container** - uses dfc in a manually started container. The script will prompt you for manual starting and stopping of the container.</br>
- **manual-app** - uses dfc app started as an external process (from eclipse etc). The script will prompt you for manual start and stop of the process.</br>

When running dfc manually, either as a container or an app the ports need to be set to map the instance id of the dfc. Most test cases start dfc with index 0, then the test case expects the ports of dfc to be mapped to the standar port number. 
However, if a higher instance id than 0 is used then the mapped ports need add that index to the port number (eg, if index 2 is used the dfc need to map port 8102 and 8435 instead of the standard 8100 and 8433).

## Test case file

A test case file contains a number of steps to verify a certain functionality.
A description of the test case should be given to the `TC_ONELINE_DESCR` var. The description will be printed in the test result.

The empty template for a test case files looks like this:

(Only the parts noted with &lt; and > shall be changed.)

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

The ../common/testcase_common.sh contains all functions needed for the test case file. See the README.md file in the ../common dir for a description of all available functions.

## Test suite files

A test suite file contains one or more test cases to run in sequence.
A description of the test case should be given to the `TS_ONELINE_DESCR` var. The description will be printed in the test result.

The empty template for a test suite files looks like this:

(Only the parts noted with `<` and `>` shall be changed.)

```
#!/bin/bash

TS_ONELINE_DESCR="<test-suite-description>"

. ../common/testsuite_common.sh

suite_setup

############# TEST CASES #################

run_tc <tc-id or ts-id>.sh $1 $2
...
...

##########################################

suite_complete


```

The ../common/testsuite_common.sh contains all functions needed for a test suite file. See the README.md file in the ../common dir for a description of all available functions.

## Known limitations

When DFC has polled a new event from the MR simulator, DFC starts to check each file whether it has been already published or not. This check is done per file towards the DR simulator. 
If the event contains a large amount of files, there is a risk that DFC will flood the DR simulator with requests for these checks. The timeout in DFC for the response is currently 4 sec and the DR simulator may not be able to answer all request within the timeout.
DR simulator is single threaded. This seem to be a problem only for the first polled event. For subsequent events these requests seem to be spread out in time by DFC so the DR simulator can respond in time.
The problem is visible in the DR simulator counters `ctr_publish_query` and`ctr_publish_query_not_published` in the auto-test scripts. They will have a count slightly less (1 to 5) than the actual number of files in the event. The application log in DFC also prints a timeout error for each failed request.
A number of the test script will report failure due to this limitation in the DR simulator.

The FTP servers may deny connection when too many file download requests are made in a short time from DFC.
This is visible in the DFC application log as WARNINGs for failed downloads. However, DFC always retry the failed download a number of times to 
minimize the risk of giving up download completely for these files.
