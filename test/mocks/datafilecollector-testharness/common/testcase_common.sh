#!/bin/bash

. ../common/test_env.sh

echo "Test case started as: ${BASH_SOURCE[$i+1]} "$1 $2

# Script containing all functions needed for auto testing of test cases
# Arg: local [<image-tag>] ]| remote [<image-tag>] ]| remote-remove [<image-tag>]] | manual-container | manual-app

START_ARG=$1
IMAGE_TAG="latest"

if [ $# -gt 1 ]; then
	IMAGE_TAG=$2
fi

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
	echo "Expected arg: local [<image-tag>] ]| remote [<image-tag>] ]| remote-remove [<image-tag>]] | manual-container | manual-app"
	exit 1
elif [ $1 == "local" ]; then
	if [ -z $DFC_LOCAL_IMAGE ]; then
		echo "DFC_LOCAL_IMAGE not set in test_env"
		exit 1
	fi
	DFC_IMAGE=$DFC_LOCAL_IMAGE":"$IMAGE_TAG
elif [ $1 == "remote" ] || [ $1 == "remote-remove" ]; then
	if [ -z $DFC_REMOTE_IMAGE ]; then
		echo "DFC_REMOTE_IMAGE not set in test_env"
		exit 1
	fi
	DFC_IMAGE=$DFC_REMOTE_IMAGE":"$IMAGE_TAG
elif [ $1 == "manual-container" ] && [ $# -eq 1 ]; then
	echo "DFC is expected to be started manually as a container with name 'dfc_app'"
elif [ $1 == "manual-app" ] && [ $# -eq 1 ]; then
	echo "DFC is expected to be started manually as a java application"
else
	echo "Expected arg: local [<image-tag>] ]| remote [<image-tag>] ]| remote-remove [<image-tag>]] | manual-container | manual-app"
	exit 1
fi

# Set a description string for the test case
if [ -z "$TC_ONELINE_DESCR" ]; then
	TC_ONELINE_DESCR="<no-description>"
	echo "No test case description found, TC_ONELINE_DESCR should be set on in the test script , using "$TC_ONELINE_DESCR
fi

# Counter for test suites
if [ -f .tmp_tcsuite_ctr ]; then
	tmpval=$(< .tmp_tcsuite_ctr)
	((tmpval++))
	echo $tmpval > .tmp_tcsuite_ctr
fi

# Create a test case id, ATC (Auto Test Case), from the name of the test case script.
# FTC1.sh -> ATC == FTC1
ATC=$(basename "${BASH_SOURCE[$i+1]}" .sh)

# Create the logs dir if not already created in the current dir
if [ ! -d "logs" ]; then
    mkdir logs
fi

TESTLOGS=$PWD/logs

# Create a log dir for the test case
mkdir -p $TESTLOGS/$ATC 

# Clear the log dir for the test case
rm $TESTLOGS/$ATC/*.log &> /dev/null

# Log all output from the test case to a TC log
TCLOG=$TESTLOGS/$ATC/TC.log
exec &>  >(tee ${TCLOG})

#Variables for counting tests as well as passed and failed tests
RES_TEST=0
RES_PASS=0
RES_FAIL=0
TCTEST_START=$SECONDS

echo "-------------------------------------------------------------------------------------------------"
echo "-----------------------------------      Test case: "$ATC
echo "-----------------------------------      Started:   "$(date)
echo "-------------------------------------------------------------------------------------------------"
echo "-- Description: "$TC_ONELINE_DESCR
echo "-------------------------------------------------------------------------------------------------"
echo "-----------------------------------      Test case setup      -----------------------------------"

if [ -z "$SIM_GROUP" ]; then
		SIM_GROUP=$PWD/../simulator-group
		if [ ! -d  $SIM_GROUP ]; then
			echo "Trying to set env var SIM_GROUP to dir 'simulator-group' in the integration repo, but failed."
			echo "Please set the SIM_GROUP manually in the test_env.sh"
			exit 1
		else 
			echo "SIM_GROUP auto set to: " $SIM_GROUP
		fi
elif [ $SIM_GROUP = *simulator_group ]; then
			echo "Env var SIM_GROUP does not seem to point to dir 'simulator-group' in the integration repo, check test_env.sh"
			exit 1
fi

echo ""

if [ $1 !=  "manual-container" ] && [ $1 !=  "manual-app" ]; then
	echo -e "DFC image tag set to: \033[1m" $IMAGE_TAG"\033[0m"
	echo "Configured image for DFC app (${1}): "$DFC_IMAGE 
	tmp_im=$(docker images ${DFC_IMAGE} | grep -v REPOSITORY)

	if [ $1 == "local" ]; then
		if [ -z "$tmp_im" ]; then
			echo "Local image (non nexus) "$DFC_IMAGE" does not exist in local registry, need to be built"
			exit 1
		else
			echo -e "DFC local image: \033[1m"$tmp_im"\033[0m"
			echo "If the DFC image seem outdated, rebuild the image and run the test again."
		fi
	elif [ $1 == "remote" ] || [ $1 == "remote-remove" ]; then

		if [ $1 == "remote-remove" ]; then
			echo "Attempt to stop dfc_app container if running"
			docker stop $(docker ps -q --filter name=dfc_app) &> /dev/null
			docker rm $(docker ps -q --filter name=dfc_app) &> /dev/null
			docker rmi $DFC_IMAGE &> /dev/null
			tmp_im=""
		fi
		if [ -z "$tmp_im" ]; then
			echo "Pulling DFC image from nexus: "$DFC_IMAGE
			docker pull $DFC_IMAGE	 > /dev/null
			tmp_im=$(docker images ${DFC_IMAGE} | grep -v REPOSITORY)
			if [ -z "$tmp_im" ]; then
				echo "Image could not be pulled"
				exit 1
			fi
			echo -e "DFC image: \033[1m"$tmp_im"\033[0m"
		else 
			echo -e "DFC image: \033[1m"$tmp_im"\033[0m"
			echo "!! If the dfc image seem outdated, consider removing it from your docker registry and run the test again."
		fi
	fi
fi

echo ""

echo "Building images for the simulators if needed, MR, DR and DR Redir simulators"
curdir=$PWD
cd $SIM_GROUP
cd ../dr-sim
docker build -t drsim_common:latest . &> /dev/null
cd ../mr-sim
docker build -t mrsim:latest . &> /dev/null
cd ../simulator-group
cp -r ../ftps-sftp-server/configuration .
cp -r ../ftps-sftp-server/tls .
cd $curdir

echo ""

echo "Local registry images for simulators:"
echo "MR simulator        " $(docker images | grep mrsim)
echo "DR simulator:       " $(docker images | grep drsim_common)
echo "DR redir simulator: " $(docker images | grep drsim_common)
echo "SFTP:               " $(docker images | grep atmoz/sftp)
echo "FTPS:               " $(docker images | grep panubo/vsftpd)
echo ""

echo "-----------------------------------      Test case steps      -----------------------------------"

# Print error info for the call in the parent script (test case). Arg: <error-message-to-print>
# Not to be called from test script.
print_err() {
    echo ${FUNCNAME[1]} " "$1" " ${BASH_SOURCE[$i+2]} " line" ${BASH_LINENO[$i+1]}
}
# Execute curl using the host and variable. Arg: <host> <variable-name>
# Returns the variable value (if success) and return code 0 or an error message and return code 1
do_curl() {
	res=$(curl -sw "%{http_code}" $1)
	http_code="${res:${#res}-3}"
	if [ ${#res} -eq 3 ]; then
  		echo "<no-response-from-server>"
		return 1
	else
		if [ $http_code -lt 200 ] && [ $http_code -gt 299]; then
			echo "<not found, resp:${http_code}>"
			return 1
		fi
  		echo "${res:0:${#res}-3}"
		return 0
	fi
}

# Test a simulator variable value towards  target value using an condition operator with an optional timeout.
# Arg: <simulator-name> <host> <variable-name> <condition-operator> <target-value>  - This test is done 
# immediately and sets pass or fail depending on the result of comparing variable and target using the operator.
# Arg: <simulator-name> <host> <variable-name> <condition-operator> <target-value> <timeout>  - This test waits up to the timeout
# before setting pass or fail depending on the result of comparing variable and target using the operator.
# Not to be called from test script.

var_test() {
	if [ $# -eq 6 ]; then
		echo -e "---- ${1} sim test criteria: \033[1m ${3} \033[0m ${4} ${5} within ${6} seconds ----"
		((RES_TEST++))
		start=$SECONDS
		ctr=0
		for (( ; ; ))
		do
			result="$(do_curl $2$3)"
			retcode=$?
			result=${result//[[:blank:]]/} #Strip blanks
			duration=$((SECONDS-start))
			if [ $((ctr%30)) -eq 0 ]; then
				echo -ne "  Result=${result} after ${duration} seconds, DFC heartbeat="$(do_curl http://127.0.0.1:8100/heartbeat)
				echo ""
			else
				echo -ne "  Result=${result} after ${duration} seconds\033[0K\r"
			fi
			let ctr=ctr+1
			if [ $retcode -ne 0 ]; then
				if [ $duration -gt $6 ]; then
					((RES_FAIL++))
					echo -e "----  \033[31m\033[1mFAIL\033[0m - Target ${3} ${4} ${5}  not reached in ${6} seconds, result = ${result} ----"
					return
				fi
			elif [ $4 = "=" ] && [ "$result" -eq $5 ]; then
				((RES_PASS++))
				echo -e "  Result=${result} after ${duration} seconds\033[0K\r"
				echo -e "----  \033[32m\033[1mPASS\033[0m - Test criteria met in ${duration} seconds ----"
				return
			elif [ $4 = ">" ] && [ "$result" -gt $5 ]; then
				((RES_PASS++))
				echo -e "  Result=${result} after ${duration} seconds\033[0K\r"
				echo -e "----  \033[32m\033[1mPASS\033[0m - Test criteria met in ${duration} seconds, result = ${result}  ----"
				return
			elif [ $4 = "<" ] && [ "$result" -lt $5 ]; then
				((RES_PASS++))
				echo -e "  Result=${result} after ${duration} seconds\033[0K\r"
				echo -e "----  \033[32m\033[1mPASS\033[0m - Test criteria met in ${duration} seconds, result = ${result}  ----"
				return
			elif [ $4 = "contain_str" ] && [[ $result =~ $5 ]]; then
				((RES_PASS++))
				echo -e "  Result=${result} after ${duration} seconds\033[0K\r"
				echo -e "----  \033[32m\033[1mPASS\033[0m - Test criteria met in ${duration} seconds, result = ${result}  ----"
				return
			else
				if [ $duration -gt $6 ]; then
					((RES_FAIL++))
					echo -e "----  \033[31m\033[1mFAIL\033[0m - Target ${3} ${4} ${5}  not reached in ${6} seconds, result = ${result} ----"
					return
				fi
			fi
			sleep 1
		done
	elif [ $# -eq 5 ]; then
		echo -e "---- ${1} sim test criteria: \033[1m ${3} \033[0m ${4} ${5} ----"
		((RES_TEST++))
		result="$(do_curl $2$3)"
		retcode=$?
		result=${result//[[:blank:]]/}  #Strip blanks
		if [ $retcode -ne 0 ]; then
			((RES_FAIL++))
			echo -e "----  \033[31m\033[1mFAIL\033[0m - Target ${3} ${4} ${5} not reached, result = ${result} ----"
		elif [ $4 = "=" ] && [ "$result" -eq $5 ]; then
			((RES_PASS++))
			echo -e "----  \033[32m\033[1mPASS\033[0m - Test criteria met"
		elif [ $4 = ">" ] && [ "$result" -gt $5 ]; then
			((RES_PASS++))
			echo -e "----  \033[32m\033[1mPASS\033[0m - Test criteria met, result = ${result} ----"
		elif [ $4 = "<" ] && [ "$result" -lt $5 ]; then
			((RES_PASS++))
			echo -e "----  \033[32m\033[1mPASS\033[0m - Test criteria met, result = ${result} ----"
		elif [ $4 = "contain_str" ] && [[ $result =~ $5 ]]; then
			((RES_PASS++))
			echo -e "----  \033[32m\033[1mPASS\033[0m - Test criteria met, result = ${result} ----"
		else
			((RES_FAIL++))
			echo -e "----  \033[31m\033[1mFAIL\033[0m - Target ${3} ${4} ${5} not reached, result = ${result} ----"
		fi
	else 
		echo "Wrong args to var_test, needs five or six args: <simulator-name> <host> <variable-name> <condition-operator> <target-value> [ <timeout> ]"
		exit 1
	fi
}
# Stops a named container
docker_stop() {
	if [ $# -ne 1 ]; then
		echo "docker_stop need 1 arg <container-name>"
		exit 1
	fi
	tmp=$(docker stop $1  2>/dev/null)
	if [ -z $tmp ] || [ $tmp != $1 ]; then
		echo " ${1} container not stopped or not existing"
	else
		echo " ${1} container stopped"
	fi
}

# Removes a named container
docker_rm() {
	if [ $# -ne 1 ]; then
		echo "docker_rm need 1 arg <container-name>"
		exit 1
	fi
	tmp=$(docker rm $1  2>/dev/null)
	if [ -z $tmp ] || [ $tmp != $1 ]; then
		echo " ${1} container not removed or not existing"
	else
		echo " ${1} container removed"
	fi
}

start_dfc_image() {
	echo "Starting DFC"
	# Port mappning not needed since dfc is running in host mode
	docker run -d --network="host" --name dfc_app $DFC_IMAGE > /dev/null
	dfc_started=false
	for i in {1..10}; do
	if [ $(docker inspect --format '{{ .State.Running }}' dfc_app) ]
 	then
	 	echo " Image: $(docker inspect --format '{{ .Config.Image }}' dfc_app)"
   		echo "DFC app Running"
		dfc_started=true
   		break
 	else
   		echo sleep $i
 	fi
	done
	if ! [ $dfc_started  ]; then
		echo "DFC app could not be started"
		exit 1
	fi
}

#WFunction for waiting for named container to be started manually.
wait_for_container() {
	start=$SECONDS
	if [ $# != 1 ]; then
		echo "Need one arg: <container-name>"
		exit 1
	fi
	echo "Waiting for container with name '${1}' to be started manually...."
		
	for (( ; ; ))
	do
		if [ $(docker inspect --format '{{ .State.Running }}' $1 2> /dev/null) ]; then
   			echo "Container running: "$1
   			break
 		else
	 		duration=$((SECONDS-start))
			echo -ne "  Waited ${duration} seconds\033[0K\r"
   			sleep 1
 		fi 
	done
}

#WFunction for waiting for named container to be stopped manually. 
wait_for_container_gone() {
	start=$SECONDS
	if [ $# != 1 ]; then
		echo "Need one arg: <container-name>"
		exit 1
	fi
	echo "Waiting for container with name '${1}' to be stopped manually...."

	for (( ; ; ))
	do
		if [ $(docker inspect --format '{{ .State.Running }}' $1 2> /dev/null) ]; then
	 		duration=$((SECONDS-start))
			echo -ne "  Waited ${duration} seconds\033[0K\r"
   			sleep 1
		else
   			echo "Container stopped: "$1
   			break
 		fi 
	done
}

#Function for waiting to dfc to be started manually
wait_for_dfc() {
	read -p "Press enter to continue when dfc has been manually started"
}

#Function for waiting to dfc to be stopped manually
wait_for_dfc_gone() {
	read -p "Press enter to continue when dfc has been manually stopped"
}

#############################################################
############## Functions for auto test scripts ##############
#############################################################

# Print the env variables needed for the simulators and their setup
log_sim_settings() {
	echo "Simulator settings"
	echo "DR_TC=        "$DR_TC
	echo "DR_REDIR_TC=  "$DR_REDIR_TC
	echo "MR_TC=        "$MR_TC
	echo "BC_TC=        "$BC_TC
	echo "NUM_FTPFILES= "$NUM_FTPFILES
	echo "NUM_PNFS=     "$NUM_PNFS
	echo "FILE_SIZE=    "$FILE_SIZE
	echo "FTP_TYPE=     "$FTP_TYPE
	echo ""
}

# Stop and remove all containers including dfc app and simulators
clean_containers() {
	echo "Stopping all containers, dfc app and simulators with name prefix 'dfc_'"
	docker stop $(docker ps -q --filter name=dfc_) &> /dev/null
	echo "Removing all containers, dfc app and simulators with name prefix 'dfc_'"
	docker rm $(docker ps -a -q --filter name=dfc_) &> /dev/null
	echo ""
}

# Start all simulators in the simulator group
start_simulators() {
	echo "Starting all simulators"
	curdir=$PWD
	cd $SIM_GROUP
	$SIM_GROUP/simulators-start.sh
	cd $curdir
	echo ""
}

# Start the dfc application
start_dfc() {

	if [ $START_ARG == "local" ] || [ $START_ARG == "remote" ] ||  [ $START_ARG == "remote-remove" ]; then
		start_dfc_image
	elif [ $START_ARG == "manual-container" ]; then
		wait_for_container dfc_app
	elif [ $START_ARG == "manual-app" ]; then
		wait_for_dfc
	fi
}

# Stop and remove the dfc app container
kill_dfc() {
	echo "Killing DFC"

	if [ $START_ARG == "local" ] || [ $START_ARG == "remote" ] ||  [ $START_ARG == "remote-remove" ]; then
		docker_stop dfc_app
		docker_rm dfc_app
	elif [ $START_ARG == "manual-container" ]; then
		wait_for_container_gone dfc_app
	elif [ $START_ARG == "manual-app" ]; then
		wait_for_dfc_gone
	fi
}

# Stop and remove the DR simulator container
kill_dr() {
	echo "Killing DR sim"
	docker_stop dfc_dr-sim
	docker_rm dfc_dr-sim
}

# Stop and remove the DR redir simulator container
kill_drr() {
	echo "Killing DR redir sim"
	docker_stop dfc_dr-redir-sim
	docker_rm dfc_dr-redir-sim
}

# Stop and remove the MR simulator container
kill_mr() {
	echo "Killing MR sim"
	docker_stop dfc_mr-sim
	docker_rm dfc_mr-sim
}

# Stop and remove the SFTP container
kill_sftp() {
	echo "Killing SFTP"
	docker_stop dfc_sftp-server
	docker_rm dfc_sftp-server
}

# Stop and remove the FTPS container
kill_ftps() {
	echo "Killing FTPS"
	docker_stop dfc_ftpes-server-vsftpd
	docker_rm dfc_ftpes-server-vsftpd
}

# Print a variable value from the MR simulator. Arg: <variable-name>
mr_print() {
	if [ $# != 1 ]; then
    	print_err "need one arg, <sim-param>"
		exit 1
	fi
	echo -e "---- MR sim, \033[1m $1 \033[0m: $(do_curl http://127.0.0.1:2222/$1)"
}

# Print a variable value from the DR simulator. Arg: <variable-name>
dr_print() {
	if [ $# != 1 ]; then
    	print_err "need one arg, <sim-param>"
		exit 1
	fi
	echo -e "---- DR sim, \033[1m $1 \033[0m: $(do_curl http://127.0.0.1:3906/$1)"
}

# Print a variable value from the DR redir simulator. Arg: <variable-name>
drr_print() {
	if [ $# != 1 ]; then
    	print_err "need one arg, <sim-param>"
		exit 1
	fi
	echo -e "---- DR redir sim, \033[1m $1 \033[0m: $(do_curl http://127.0.0.1:3908/$1)"
}
# Print a variable value from dfc. Arg: <variable-name>
dfc_print() {
	if [ $# != 1 ]; then
    	print_err "need one arg, <dfc-param>"
		exit 1
	fi
	echo -e "---- DFC, \033[1m $1 \033[0m: $(do_curl http://127.0.0.1:8100/$1)"
}

# Read a variable value from MR sim and send to stdout.
mr_read() {
	echo "$(do_curl http://127.0.0.1:2222/$1)"
}

# Read a variable value from DR sim and send to stdout.
dr_read() {
	echo "$(do_curl http://127.0.0.1:3906/$1)"
}

# Read a variable value from DR redir sim and send to stdout.
drr_read() {
	echo "$(do_curl http://127.0.0.1:3908/$1)"
}


# Sleep. Arg: <sleep-time-in-sec>
sleep_wait() {
	if [ $# != 1 ]; then
		print_err "need one arg, <sleep-time-in-sec>"
		exit 1
	fi
	echo "---- Sleep for " $1 " seconds ----"
	start=$SECONDS
	duration=$((SECONDS-start))
	while [ $duration -lt $1 ]; do
		echo -ne "  Slept for ${duration} seconds\033[0K\r"
		sleep 1
		duration=$((SECONDS-start))
	done
}

# Sleep and print dfc heartbeat. Arg: <sleep-time-in-sec>
sleep_heartbeat() {
	if [ $# != 1 ]; then
		print_err "need one arg, <sleep-time-in-sec>"
		exit 1
	fi
	echo "---- Sleep for " $1 " seconds ----"
	start=$SECONDS
	duration=$((SECONDS-start))
	ctr=0
	while [ $duration -lt $1 ]; do
		if [ $((ctr%30)) -eq 0 ]; then
			echo -ne "  Slept for ${duration} seconds, \033[1m heartbeat \033[0m "$(do_curl http://127.0.0.1:8100/heartbeat)
			echo ""
		else
			echo -ne "  Slept for ${duration} seconds, \033[1m heartbeat \033[0m "$(do_curl http://127.0.0.1:8100/heartbeat)" \033[0K\r"
		fi
		let ctr=ctr+1
		sleep 1
		duration=$((SECONDS-start))
	done
	echo ""
}

# Tests if a variable value in the MR simulator is equal to a target value and and optional timeout.
# Arg: <variable-name> <target-value> - This test set pass or fail depending on if the variable is
# equal to the target or not.
# Arg: <variable-name> <target-value> <timeout-in-sec>  - This test waits up to the timeout seconds
# before setting pass or fail depending on if the variable value becomes equal to the target
# value or not.
mr_equal() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		var_test "MR" "http://127.0.0.1:2222/" $1 "=" $2 $3
	else
		print_err "Wrong args to mr_equal, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}

# Tests if a variable value in the MR simulator is greater than a target value and and optional timeout.
# Arg: <variable-name> <target-value> - This test set pass or fail depending on if the variable is
# greater than the target or not.
# Arg: <variable-name> <target-value> <timeout-in-sec>  - This test waits up to the timeout seconds
# before setting pass or fail depending on if the variable value greater than the target
# value or not.
mr_greater() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		var_test "MR" "http://127.0.0.1:2222/" $1 ">" $2 $3
	else
		print_err "Wrong args to mr_greater, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}

# Tests if a variable value in the MR simulator is less than a target value and and optional timeout.
# Arg: <variable-name> <target-value> - This test set pass or fail depending on if the variable is
# less than the target or not.
# Arg: <variable-name> <target-value> <timeout-in-sec>  - This test waits up to the timeout seconds
# before setting pass or fail depending on if the variable value less than the target
# value or not.
mr_less() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		var_test "MR" "http://127.0.0.1:2222/" $1 "<" $2 $3
	else
		print_err "Wrong args to mr_less, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}

# Tests if a variable value in the MR simulator contains the target string and and optional timeout.
# Arg: <variable-name> <target-value> - This test set pass or fail depending on if the variable contains
# the target or not.
# Arg: <variable-name> <target-value> <timeout-in-sec>  - This test waits up to the timeout seconds
# before setting pass or fail depending on if the variable value contains the target
# value or not.
mr_contain_str() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		var_test "MR" "http://127.0.0.1:2222/" $1 "contain_str" $2 $3
	else
		print_err "Wrong args to mr_contain_str, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}

# Tests if a variable value in the DR simulator is equal to a target value and and optional timeout.
# Arg: <variable-name> <target-value> - This test set pass or fail depending on if the variable is
# equal to the target or not.
# Arg: <variable-name> <target-value> <timeout-in-sec>  - This test waits up to the timeout seconds
# before setting pass or fail depending on if the variable value becomes equal to the target
# value or not.
dr_equal() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		var_test "DR" "http://127.0.0.1:3906/" $1 "=" $2 $3
	else
		print_err "Wrong args to dr_equal, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}

# Tests if a variable value in the DR simulator is greater than a target value and and optional timeout.
# Arg: <variable-name> <target-value> - This test set pass or fail depending on if the variable is
# greater than the target or not.
# Arg: <variable-name> <target-value> <timeout-in-sec>  - This test waits up to the timeout seconds
# before setting pass or fail depending on if the variable value greater than the target
# value or not.
dr_greater() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		var_test "DR" "http://127.0.0.1:3906/" $1 ">" $2 $3
	else
		print_err "Wrong args to dr_greater, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}

# Tests if a variable value in the DR simulator is less than a target value and and optional timeout.
# Arg: <variable-name> <target-value> - This test set pass or fail depending on if the variable is
# less than the target or not.
# Arg: <variable-name> <target-value> <timeout-in-sec>  - This test waits up to the timeout seconds
# before setting pass or fail depending on if the variable value less than the target
# value or not.
dr_less() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		var_test "DR" "http://127.0.0.1:3906/" $1 "<" $2 $3
	else
		print_err "Wrong args to dr_less, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}

# Tests if a variable value in the DR Redir simulator is equal to a target value and and optional timeout.
# Arg: <variable-name> <target-value> - This test set pass or fail depending on if the variable is
# equal to the target or not.
# Arg: <variable-name> <target-value> <timeout-in-sec>  - This test waits up to the timeout seconds
# before setting pass or fail depending on if the variable value becomes equal to the target
# value or not.
drr_equal() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		var_test "DR REDIR" "http://127.0.0.1:3908/" $1 "=" $2 $3
	else
		print_err "Wrong args to drr_equal, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}


# Tests if a variable value in the DR Redir simulator is greater a target value and and optional timeout.
# Arg: <variable-name> <target-value> - This test set pass or fail depending on if the variable is
# greater the target or not.
# Arg: <variable-name> <target-value> <timeout-in-sec>  - This test waits up to the timeout seconds
# before setting pass or fail depending on if the variable value greater than the target
# value or not.
drr_greater() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		var_test "DR REDIR" "http://127.0.0.1:3908/" $1 ">" $2 $3
	else
		print_err "Wrong args to drr_greater, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}

# Tests if a variable value in the DR Redir simulator is less than a target value and and optional timeout.
# Arg: <variable-name> <target-value> - This test set pass or fail depending on if the variable is
# less than the target or not.
# Arg: <variable-name> <target-value> <timeout-in-sec>  - This test waits up to the timeout seconds
# before setting pass or fail depending on if the variable value less than the target
# value or not.
drr_less() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		var_test "DR REDIR" "http://127.0.0.1:3908/" $1 "<" $2 $3
	else
		print_err "Wrong args to drr_less, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}

#Test is a variable in the DFC contains a substring. Arg: <variable-name> <substring-in-quotes>
dfc_contain_str() {
	if [ $# -eq 2 ]; then
		echo -e "---- DFC test criteria: \033[1m ${1} \033[0m contains: ${2} ----"
		((RES_TEST++))
		result="$(do_curl http://127.0.0.1:8100/${1})"
		if [[ $result =~ $2 ]]; then
			((RES_PASS++))
			echo -e "----  \033[32m\033[1mPASS\033[0m - Test criteria met"		
		else
			((RES_FAIL++))
			echo -e "----  \033[31m\033[1mFAIL\033[0m - Target ${1} not reached, result = ${result} ----"
		fi
	else 
		echo "Wrong args to dfc_contain_str, needs two arg: <dfc-variable> <str>"
		exit 1
	fi
}

# Store all dfc app and simulators log to the test case log dir. All logs gets a prefix to
# separate logs stored at different steps in the test script. Arg: <tc-id> <log-prefix>
store_logs() {
	if [ $# != 1 ]; then
    	print_err "need one arg, <file-prefix>"
		exit 1
	fi
	echo "Storing all container logs and dfc app log using prefix: "$1
	if ! [ $START_ARG == "manual-app" ]; then
		docker cp dfc_app:/var/log/ONAP/application.log $TESTLOGS/$ATC/$1_application.log
		docker logs dfc_app > $TESTLOGS/$ATC/$1_dfc_app-docker.log 2>&1
	fi
	docker logs dfc_mr-sim > $TESTLOGS/$ATC/$1_dfc_mr-sim-docker.log 2>&1
	docker logs dfc_dr-sim > $TESTLOGS/$ATC/$1_dfc_dr-sim-docker.log 2>&1
	docker logs dfc_dr-redir-sim > $TESTLOGS/$ATC/$1_dfc_dr-redir-sim-docker.log 2>&1
	docker logs dfc_ftpes-server-vsftpd > $TESTLOGS/$ATC/$1_dfc_ftpes-server-vsftpd.log 2>&1
	docker logs dfc_sftp-server > $TESTLOGS/$ATC/$1_dfc_sftp-server.log 2>&1
}
# Check the dfc application log for WARN and ERR messages and print the count.
check_dfc_log() {
	echo "Checking dfc log /var/log/ONAP/application.log for WARNINGs and ERRORs, excluding messages from CONSUL"
	foundentries=$(docker exec -it dfc_app grep WARN /var/log/ONAP/application.log | grep -iv CONSUL | wc -l)
	if [ $? -ne  0 ];then
		echo "  Problem to search dfc log /var/log/ONAP/application.log"
	else
		if [ $foundentries -eq 0 ]; then
			echo "  No WARN entries found in dfc log /var/log/ONAP/application.log"
		else 
			echo -e "  Found \033[1m"$foundentries"\033[0m WARN entries in dfc log /var/log/ONAP/application.log"
		fi
	fi
		foundentries=$(docker exec -it dfc_app grep ERR /var/log/ONAP/application.log | grep -iv CONSUL | wc -l)
	if [ $? -ne  0 ];then
		echo "  Problem to search dfc log /var/log/ONAP/application.log"
	else
		if [ $foundentries -eq 0 ]; then
			echo "  No ERR entries found in dfc log /var/log/ONAP/application.log"
		else 
			echo -e "  Found \033[1m"$foundentries"\033[0m ERR entries in dfc log /var/log/ONAP/application.log"
		fi
	fi
}

print_all() {

	echo "---- DFC and all sim variables"

	dfc_print heartbeat
	
	mr_print tc_info
	mr_print execution_time
	mr_print exe_time_first_poll
	mr_print ctr_requests
	mr_print ctr_responses
	mr_print ctr_files
	mr_print ctr_unique_files
	mr_print ctr_events
	mr_print ctr_unique_PNFs

	dr_print tc_info
	dr_print execution_time
	dr_print ctr_publish_query
	dr_print ctr_publish_query_published
	dr_print ctr_publish_query_not_published
	dr_print ctr_publish_req
	dr_print ctr_publish_req_redirect
	dr_print ctr_publish_req_published
	dr_print ctr_published_files

	drr_print tc_info
	drr_print execution_time
	drr_print ctr_publish_requests
	drr_print ctr_publish_responses
	drr_print dwl_volume
	drr_print time_lastpublish
}

# Print the test result 
print_result() {

	TCTEST_END=$SECONDS
	duration=$((TCTEST_END-TCTEST_START))

	echo "-------------------------------------------------------------------------------------------------"
	echo "-------------------------------------     Test case: "$ATC
	echo "-------------------------------------     Ended:     "$(date)
	echo "-------------------------------------------------------------------------------------------------"
	echo "-- Description: "$TC_ONELINE_DESCR
	echo "-- Execution time: " $duration " seconds"
	echo "-------------------------------------------------------------------------------------------------"
	echo "-------------------------------------     RESULTS"
	echo ""


	total=$((RES_PASS+RES_FAIL))
	if [ $RES_TEST -eq 0 ]; then
		echo -e "\033[1mNo tests seem to have executed. Check the script....\033[0m"
	elif [ $total != $RES_TEST ]; then
		echo -e "\033[1mTotal number of tests does not match the sum of passed and failed tests. Check the script....\033[0m"
	elif [ $RES_PASS = $RES_TEST ]; then
		echo -e "All tests \033[32m\033[1mPASS\033[0m"
		# Update test suite counter
		if [ -f .tmp_tcsuite_pass_ctr ]; then
			tmpval=$(< .tmp_tcsuite_pass_ctr)
			((tmpval++))
			echo $tmpval > .tmp_tcsuite_pass_ctr
		fi
		if [ -f .tmp_tcsuite_pass ]; then
			echo " - "$ATC " -- "$TC_ONELINE_DESCR"  Execution time: "$duration" seconds" >> .tmp_tcsuite_pass
		fi
	else
		echo -e "One or more tests with status  \033[31m\033[1mFAIL\033[0m "
		# Update test suite counter
		if [ -f .tmp_tcsuite_fail_ctr ]; then
			tmpval=$(< .tmp_tcsuite_fail_ctr)
			((tmpval++))
			echo $tmpval > .tmp_tcsuite_fail_ctr
		fi
		if [ -f .tmp_tcsuite_fail ]; then
			echo " - "$ATC " -- "$TC_ONELINE_DESCR"  Execution time: "$duration" seconds" >> .tmp_tcsuite_fail
		fi
	fi

	echo "++++ Number of tests:        "$RES_TEST
	echo "++++ Number of passed tests: "$RES_PASS
	echo "++++ Number of failed tests: "$RES_FAIL
	echo "-------------------------------------     Test case complete    ---------------------------------"
	echo "-------------------------------------------------------------------------------------------------"
	echo ""
}
