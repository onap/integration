# MR-simulator

This readme contains:

- Introduction
- Building and running
- Configuration

## Introduction

The MR-sim is a python script delivering batches of events including one or more fileReady for one or more PNFs.
It is possible to configure number of events, PNFs, consumer groups, exising or missing files, file prefixes and change identifier.
In addition, MR sim can be configured to deliver file url for up to 5 FTP servers (simulating the PNFs).

## Building and running

It is possible build and run MR-sim manually as a container if needed. In addition MR-sim can be executed as python script, see instuctions further down.
Otherwise it is recommended to use the test scripts in the auto-test dir or run all simulators in one go using scripts in the simulator-group dir.

To build and run manually as a docker container:

1. Build docker container with `docker build -t mrsim:latest .`
2. Run the container `docker-compose up`

## Configuration

The event pattern, called TC, of the MR-sim is controlled with a arg to python script. See section TC info for available patterns.
All other configuration is done via envrionment variables.
The simulator listens to port 2222.

The following envrionment vaiables are used:

- **FTPS_SIMS** - A comma-separated list of hostname:port for the FTP servers to generate ftps file urls for. If not set MR sim will assume 'localhost:21'. Minimum 1 and maximum 5 host-port pairs can be given.
- **SFTP_SIMS** - A comma-separated list of hostname:port for the FTP servers to generate sftp file urls for. If not set MR sim will assume 'localhost:1022'. Minimum 1 and maximum 5 host-port pairs can be given.
- **NUM_FTP_SERVERS** - Number of FTP servers to use out of those specified in the envrioment variables above. The number shall be in the range 1-5.
- **MR_GROUPS** - A comma-separated list of consummer-group:changeId[:changeId]\*. Defines which change identifier that should be used for each consumer gropu. If not set the MR-sim will assume 'OpenDcae-c12:PM_MEAS_FILES'.
- **MR_FILE_PREFIX_MAPPING** - A comma-separated list of changeId:filePrefix. Defines which file prefix to use for each change identifier, needed to distinguish files for each change identifiers. If not set the MR-sim will assume 'PM_MEAS_FILES:A

## Statistics read-out and commands

The simulator can be queried for statistics  and  started/stopped (use curl from cmd line or open in browser, curl used below):

`curl localhost:2222` - Just returns 'Hello World'.

`curl localhost:2222/tc_info` - returns the tc string (as given on the cmd line)

`curl localhost:2222/start` - start event delivery (default status).

`curl localhost:2222/stop` - stop event delivery.

`curl localhost:2222/status` - returns the status, started or stopped .

`curl localhost:2222/execution_time` - returns the execution time in mm:ss

`curl localhost:2222/groups` - returns a comma-separated list of configured consumer groups..

`curl localhost:2222/changeids` - returns a commar-separated list of configured change id sets, where each set is a list of colon-separated change for each configured consumer group.

`curl localhost:2222/fileprefixes` - returns the setting of env var MR_FILE_PREFIX_MAPPING.

`curl localhost:2222/ctr_requests`   - returns an integer of the number of get requests, for all groups,  to the event poll path

`curl localhost:2222/groups/ctr_requests`   - returns a list of integers of the number of get requests, for each consumer group, to the event poll path

`curl localhost:2222/ctr_requests/<consumer-group>`   - returns an integer of the number of get requests, for the specified consumer group, to the event poll path

`curl localhost:2222/ctr_responses`   - returns an integer of the number of get responses, for all groups,  to the event poll path

`curl localhost:2222/groups/ctr_responses`   - returns a list of integers of the number of get responses, for each consumer group, to the event poll path

`curl localhost:2222/ctr_responses/<consumer-group>`   - returns an integer of the number of get responses, for the specified consumer group, to the event poll path

`curl localhost:2222/ctr_files` - returns an integer of the number generated files for all groups

`curl localhost:2222/groups/ctr_files` - returns a list of integers of the number generated files for each group

`curl localhost:2222/ctr_files/<consumer-group>` - returns an integer or the number generated files for the specified group

`curl localhost:2222/ctr_unique_files` - returns an integer of the number generated unique files for all groups

`curl localhost:2222/groups/ctr_unique_files` - returns a list of integers of the number generated unique files for each group

`curl localhost:2222/ctr_unique_files/<consumer-group>` - returns an integer or the number generated unique files for the specified group

`curl localhost:2222/ctr_events` - returns the total number of events for all groups

`curl localhost:2222/groups/ctr_events` - returns a list the integer of the total number of events for each group

`curl localhost:2222/ctr_events/<consumer-group>` - returns the total number of events for a specified group

`curl localhost:2222/exe_time_first_poll` - returns the execution time in mm:ss from the first poll

`curl localhost:2222/groups/exe_time_first_poll` - returns a list of the execution time in mm:ss from the first poll for each group

`curl localhost:2222/exe_time_first_poll/<consumer-group>` - returns the execution time in mm:ss from the first poll for the specified group

`curl localhost:2222/ctr_unique_PNFs` - returns the number of unique PNFS in all events.

`curl localhost:2222/groups/ctr_unique_PNFs` - returns a list of the number of unique PNFS in all events for each group.

`curl localhost:2222/ctr_unique_PNFs/<consumer-group>` - returns the number of unique PNFS in all events for the specified group.

## Alternative to running python (as described below) on your machine, use the docker files

1. Build docker container with `docker build -t mrsim:latest .`
2. Run the container `docker-compose up`
   The behavior can be changed by argument to the python script in the docker-compose.yml

## Common TC info

File names for 1MB, 5MB and 50MB files
Files in the format: <size-in-mb>MB\_<sequence-number>.tar.gz    Ex. for 5MB file with sequence number 12:  5MB_12.tar.gz
The sequence numbers are stepped so that all files have unique names
Missing files (files that are not expected to be found in the ftp server. Format: MissingFile\*<sequence-number>.tar.gz

When the number of events are exhausted, empty replies are returned '\[]', for the limited test cases. For endless tc no empty replies will be given.

Test cases are limited unless noted as 'endless'.

TC100 - One ME, SFTP, 1 1MB file, 1 event

TC101 - One ME, SFTP, 1 5MB file, 1 event

TC102 - One ME, SFTP, 1 50MB file, 1 event

TC110 - One ME, SFTP, 1MB files, 1 file per event, 100 events, 1 event per poll.

TC111 - One ME, SFTP, 1MB files, 100 files per event, 100 events, 1 event per poll.

TC112 - One ME, SFTP, 5MB files, 100 files per event, 100 events, 1 event per poll.

TC113 - One ME, SFTP, 1MB files, 100 files per event, 100 events. All events in one poll.

TC120 - One ME, SFTP, 1MB files, 100 files per event, 100 events, 1 event per poll. 10% of replies each: no response, empty message, slow response, 404-error, malformed json

TC121 - One ME, SFTP, 1MB files, 100 files per event, 100 events, 1 event per poll. 10% missing files

TC122 - One ME, SFTP, 1MB files, 100 files per event, 100 events. 1 event per poll. All files with identical name.

TC500 - 700 MEs, SFTP, 1MB files, 2 new files per event, 700 events, all event in one poll

TC501 - 700 MEs, SFTP, 5MB files, 2 new files per event, 700 events, all event in one poll

TC502 - 700 MEs, SFTP, 50MB files, 2 new files per event, 700 events, all event in one poll

TC510 - 700 MEs, SFTP, 1MB files, 1 file per event, 3500 events, 700 event per poll.

TC511 - 700 MEs, SFTP, 1KB files, 1 file per event, 3500 events, 700 event per poll

TC550 - 700 MEs, SFTP, 50MB files, 1 file per event, 3500 events, 700 event per poll

TC710 - 700 MEs, SFTP, 1MB files, 100 files per event, 3500 events, 35 event per poll

TC1000 - One ME, SFTP, 1MB files, 100 files per event, endless number of events, 1 event per poll

TC1001 - One ME, SFTP, 5MB files, 100 files per event, endless number of events, 1 event per poll

TC1100 - 700 ME, SFTP, 1MB files, 100 files per event, endless number of events, 35 event per poll

TC1101 - 700 ME, SFTP, 5MB files, 100 files per event, endless number of events, 35 event per poll

TC1102 - 700 ME, SFTP, 50MB files, 100 files per event, endless number of events, 35 event per poll

TC1200 - 700 ME, SFTP, 1MB files, 100 new files per event, endless number of events, 35 event per poll

TC1201 - 700 ME, SFTP, 5MB files, 100 new files per event, endless number of events, 35 event per poll

TC1202 - 700 ME, SFTP, 50MB files, 100 new files per event, endless number of events, 35 event per poll

TC1300 - 700 ME, SFTP, 1MB files, 100 files per event, endless number of events, 35 event per poll, 20 event polls every 15min

TC1301 - 700 ME, SFTP, 5MB files, 100 files per event, endless number of events, 35 event per poll, 20 event polls every 15min

TC1302 - 700 ME, SFTP, 50MB files, 100 files per event, endless number of events, 35 event per poll, 20 event polls every 15min

TC1500 - 700 ME, SFTP, 1MB files, 100 files per event, 35 events per poll, simulating 25h backlog of decreasing number of outdated files and then 20 event polls every 15min for 1h

Changing the first digit in tc number will change the test case to run FTPS instead. Eg. TC201 is FTPS version of TC101.

TC2XX is same as TC1XX but with FTPS

TC6XX is same as TC5XX but with FTPS

TC8XX is same as TC7XX but with FTPS

TC2XXX is same as TC1XXX but with FTPS

## Developer workflow

1. `sudo apt install python3-venv`
2. `source .env/bin/activate/`
3. `pip3 install "anypackage"`      #also include in source code
4. `pip3 freeze | grep -v "pkg-resources" > requirements.txt`  #to create a req file
5. `FLASK_APP=mr-sim.py flask run`
   or
   `python3 mr-sim.py `
6. Check/lint/format the code before commit/amed by `autopep8 --in-place --aggressive --aggressive mr-sim.py`

## User workflow on \*NIX

When cloning/fetching from the repository first time:

1. `git clone`
2. `cd "..." ` 		#navigate to this folder
3. `source setup.sh `	#setting up virtualenv and install requirements
   you'll get a sourced virtualenv shell here, check prompt
4. `(env) $ python3 mr-sim.py --help`
   alternatively
   `(env) $ python3 mr-sim.py --tc1`

Every time you run the script, you'll need to step into the virtualenv by following step 3 first.

## User workflow on Windows

When cloning/fetching from the repository first time:

1. 'git clone'
2. then step into the folder
3. 'pip3 install virtualenv'
4. 'pip3 install virtualenvwrapper-win'
5. 'mkvirtualenv env'
6. 'workon env'
7. 'pip3 install -r requirements.txt'   #this will install in the local environment then
8. 'python3 dfc-sim.py'

Every time you run the script, you'll need to step into the virtualenv by step 2+6.
