#!/bin/bash
#
# Modifications copyright (C) 2021 Nokia. All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

. ../common/test_env.sh



echo "Test case started as: ${BASH_SOURCE[$i+1]} "$1 $2

# Script containing all functions needed for auto testing of test cases
# Arg: local [<image-tag>] ]| remote [<image-tag>] ]| remote-remove [<image-tag>]] | manual-container | manual-app

STARTED_DFCS="" #DFC app names added to this var to keep track of started container in the script
START_ARG=$1
IMAGE_TAG="latest"

if [ $# -gt 1 ]; then
	if [[ "$2" =~ ^1.1.* ]]; then
		echo "This version of auto-test does not support DFC image version of 1.1.X"
		exit 1
	fi
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
	echo "DFC is expected to be started manually, when prompted,  as a container with name 'dfc_app'<index> with and index in the range from 0 to '${DFC_MAX_IDX}'"
elif [ $1 == "manual-app" ] && [ $# -eq 1 ]; then
	echo "DFC is expected to be started manually, when prompted, as a java application"
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
	echo "Configured image for DFC app(s) (${1}): "$DFC_IMAGE
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
			echo "Attempt to stop dfc_app container(s) if running"
			docker stop $(docker ps -q --filter name=${DFC_APP_BASE}]) &> /dev/null
			docker rm $(docker ps -q --filter name=${DFC_APP_BASE}) &> /dev/null
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
			echo "!! If the dfc image seem outdated, consider removing it from your docker registry and run the test again. Or run the script with 'remote-remove'"
		fi
	fi
fi



echo ""

echo "Building images for the simulators if needed, MR, DR, DR Redir and FTPES."
echo "For HTTP simulator prebuilt containers exist in nexus repo."
curdir=$PWD
cd $SIM_GROUP
cd ../dr-sim
docker build -t drsim_common:latest . &> /dev/null
cd ../mr-sim
docker build -t mrsim:latest . &> /dev/null
cd ../ftpes-sftp-server
docker build -t ftpes_vsftpd:latest -f Dockerfile-ftpes . &> /dev/null
cd $curdir

echo ""

echo "Local registry images for simulators:"
echo "MR simulator              " $(docker images | grep mrsim)
echo "DR simulator:             " $(docker images | grep drsim_common)
echo "DR redir simulator:       " $(docker images | grep drsim_common)
echo "SFTP:                     " $(docker images | grep atmoz/sftp)
echo "FTPES:                    " $(docker images | grep ftpes_vsftpd)
echo "HTTP/HTTPS/HTTPS no auth: " $(docker images | grep http_https_httpd)
echo ""

#Configure MR sim to use correct host:port for running dfc as an app or as a container
#Configure DR sim with correct address for DR redirect simulator
if [ $START_ARG == "manual-app" ]; then
	export SFTP_SIMS=$SFTP_SIMS_LOCALHOST
	export FTPES_SIMS=$FTPES_SIMS_LOCALHOST
	export HTTP_SIMS=$HTTP_SIMS_LOCALHOST
	export HTTP_JWT_SIMS=$HTTP_JWT_SIMS_LOCALHOST
	export HTTPS_SIMS=$HTTPS_SIMS_LOCALHOST
	export HTTPS_SIMS_NO_AUTH=HTTPS_SIMS_NO_AUTH_LOCALHOST
	export HTTPS_JWT_SIMS=$HTTPS_JWT_SIMS_LOCALHOST
	export DR_REDIR_SIM="localhost"
fi
#else
#	export SFTP_SIMS=$SFTP_SIMS_CONTAINER
#	export FTPES_SIMS=$FTPES_SIMS_CONTAINER
#	export DR_REDIR_SIM="drsim_redir"
#fi

echo "-----------------------------------      Test case steps      -----------------------------------"

# Print error info for the call in the parent script (test case). Arg: <error-message-to-print>
# Not to be called from test script.
__print_err() {
    echo ${FUNCNAME[1]} " "$1" " ${BASH_SOURCE[$i+2]} " line" ${BASH_LINENO[$i+1]}
}
# Execute curl using the host and variable. Arg: <host and variable-name>  [ <flag-to-strip-new-line> ]
#<flag-to-strip-new-line> may contain any string, it is just a flag
# Returns the variable value (if success) and return code 0 or an error message and return code 1
__do_curl() {
	res=$(curl -skw "%{http_code}" $1)
	http_code="${res:${#res}-3}"
	if [ ${#res} -eq 3 ]; then
  		echo "<no-response-from-server>"
		return 1
	else
		if [ $http_code -lt 200 ] && [ $http_code -gt 299 ]; then
			echo "<not found, resp:${http_code}>"
			return 1
		fi
		if [ $# -eq 2 ]; then
  			echo "${res:0:${#res}-3}" | xargs
		else
  			echo "${res:0:${#res}-3}"
		fi

		return 0
	fi
}

# Test a simulator variable value towards  target value using an condition operator with an optional timeout.
# Arg: <simulator-name> <host> <variable-name> <condition-operator> <target-value>  - This test is done
# immediately and sets pass or fail depending on the result of comparing variable and target using the operator.
# Arg: <simulator-name> <host> <variable-name> <condition-operator> <target-value> <timeout>  - This test waits up to the timeout
# before setting pass or fail depending on the result of comparing variable and target using the operator.
# Not to be called from test script.

__var_test() {
	if [ $# -eq 6 ]; then
		echo -e "---- ${1} sim test criteria: \033[1m ${3} \033[0m ${4} ${5} within ${6} seconds ----"
		((RES_TEST++))
		start=$SECONDS
		ctr=0
		for (( ; ; ))
		do
			result="$(__do_curl $2$3)"
			retcode=$?
			result=${result//[[:blank:]]/} #Strip blanks
			duration=$((SECONDS-start))
			if [ $((ctr%30)) -eq 0 ]; then
				echo "  Result=${result} after ${duration} seconds"
				for (( i=0; i<=$DFC_MAX_IDX; i++ )); do
					if [[ $STARTED_DFCS =~ "_"$DFC_APP_BASE$i"_" ]]; then
						echo "    HB ${DFC_APP_BASE}${i}: $(__do_curl http://127.0.0.1:$(($DFC_PORT+$i))/status strip)"
					fi
				done
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
		result="$(__do_curl $2$3)"
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
		echo "Wrong args to __var_test, needs five or six args: <simulator-name> <host> <variable-name> <condition-operator> <target-value> [ <timeout> ]"
		exit 1
	fi
}
# Stops a named container
__docker_stop() {
	if [ $# -ne 1 ]; then
		echo "__docker_stop need 1 arg <container-name>"
		exit 1
	fi
	tmp=$(docker stop $1  2>/dev/null)
	if [ -z $tmp ] || [ $tmp != $1 ]; then
		echo " ${1} container not stopped or not existing"
	else
		echo " ${1} container stopped"
	fi
}

# Starts a named container (that has previously been stopped)
__docker_start() {
	if [ $# -ne 1 ]; then
		echo "__docker_start need 1 arg <container-name>"
		exit 1
	fi
	tmp=$(docker start $1  2>/dev/null)
	if [ -z $tmp ] || [ $tmp != $1 ]; then
		echo " ${1} container not started or not existing"
	else
		echo " ${1} container started"
	fi
}

# Removes a named container
__docker_rm() {
	if [ $# -ne 1 ]; then
		echo "__docker_rm need 1 arg <container-name>"
		exit 1
	fi
	tmp=$(docker rm $1  2>/dev/null)
	if [ -z $tmp ] || [ $tmp != $1 ]; then
		echo " ${1} container not removed or not existing"
	else
		echo " ${1} container removed"
	fi
}

__start_dfc_image() {
	set -x
	if [ $# != 2 ]; then
    	__print_err "need tow args, <dfc-instance-name> 0.."$$DFC_MAX_IDX
		exit 1
	fi

	if [ $2 -lt 0 ] || [ $2 -gt $DFC_MAX_IDX ]; then
		__print_err "need two args, <dfc-instance-name> 0.."$DFC_MAX_IDX
		exit 1
	fi
	appname=$1
	localport=$(($DFC_PORT + $2))
	localport_secure=$(($DFC_PORT_SECURE + $2))

	echo "Creating docker network "$DOCKER_SIM_NWNAME", if needed"

	docker network ls| grep "$DOCKER_SIM_NWNAME" > /dev/null || docker network create "$DOCKER_SIM_NWNAME"

	echo "Starting DFC: " $appname " with ports mapped to " $localport " and " $localport_secure " in docker network "$DOCKER_SIM_NWNAME
  docker run -d --volume $(pwd)/../simulator-group/tls/:/opt/app/datafile/etc/cert/ --volume $(pwd)/../simulator-group/dfc_config_volume/:/app-config/ -p $localport":8100" -p $localport_secure":8433" --network=$DOCKER_SIM_NWNAME -e CONFIG_BINDING_SERVICE=$CONFIG_BINDING_SERVICE -e CONFIG_BINDING_SERVICE_SERVICE_PORT=$CONFIG_BINDING_SERVICE_SERVICE_PORT -e HOSTNAME=$appname --name $appname $DFC_IMAGE
	sleep 3
	set +x
	dfc_started=false
	for i in {1..10}; do
		if [ $(docker inspect --format '{{ .State.Running }}' $appname) ]
		 	then
			 	echo " Image: $(docker inspect --format '{{ .Config.Image }}' ${appname})"
		   		echo "DFC container ${appname} running"
				dfc_started=true
		   		break
		 	else
		   		sleep $i
	 	fi
	done
	if ! [ $dfc_started  ]; then
		echo "DFC container ${appname} could not be started"
		exit 1
	fi

	dfc_hb=false
	echo "Waiting for DFC ${appname} heartbeat..."
	for i in {1..10}; do
		result="$(__do_curl http://127.0.0.1:${localport}/heartbeat)"
		if [ $? -eq 0 ]; then
	   		echo "DFC ${appname} responds to heartbeat: " $result
	   		dfc_hb=true
	   		result="$(__do_curl http://127.0.0.1:${localport}/actuator/info)"
	   		echo "DFC ${appname} image build info: " $result
	   		break
	 	else
	   		sleep $i
	 	fi
	done

	if [ "$dfc_hb" = "false"  ]; then
		echo "DFC ${appname} did not respond to heartbeat"
		exit 1
	fi
}

# Function for waiting for named container to be started manually.
__wait_for_container() {
	start=$SECONDS
	if [ $# != 2 ]; then
		echo "Need one arg: <container-name> <instance-id>"
		exit 1
	fi
	http=$(($DFC_PORT+$2))
	https=$((DFC_PORT_SECURE+$2))
	echo "The container is expected to map its ports (8100/8433) to the following port visibile on the host: http port ${http} and https port ${https}"
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

	echo "Connecting container "$1" to simulator network "$DOCKER_SIM_NWNAME
	docker network connect $DOCKER_SIM_NWNAME $1
}

#WFunction for waiting for named container to be stopped manually.
__wait_for_container_gone() {
	start=$SECONDS
	if [ $# != 1 ]; then
		echo "Need one arg: <container-name>"
		exit 1
	fi
	echo "Disconnecting container "$1" from simulator network "$DOCKER_SIM_NWNAME
	docker network disconnect $DOCKER_SIM_NWNAME $1
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
__wait_for_dfc() {
	http=$(($DFC_PORT+$2))
	https=$((DFC_PORT_SECURE+$2))
	echo "The app is expected to listen to http port ${http} and https port ${https}"
	echo "The app shall use ${1} for HOSTNAME."
	read -p "Press enter to continue when app mapping to ${1} has been manually started"
}

#Function for waiting to dfc to be stopped manually
__wait_for_dfc_gone() {
	read -p "Press enter to continue when when app mapping to ${1} has been manually stopped"
}

#############################################################
############## Functions for auto test scripts ##############
#############################################################

# Print the env variables needed for the simulators and their setup
log_sim_settings() {
	echo "Simulator settings"
	echo "MR_TC=                 "$MR_TC
	echo "MR_GROUPS=             "$MR_GROUPS
    echo "MR_FILE_PREFIX_MAPPING="$MR_FILE_PREFIX_MAPPING
	echo "DR_TC=                 "$DR_TC
	echo "DR_FEEDS=              "$DR_FEEDS
	echo "DR_REDIR_SIM=          "$DR_REDIR_SIM
	echo "DR_REDIR_TC=           "$DR_REDIR_TC
	echo "DR_REDIR_FEEDS=        "$DR_REDIR_FEEDS

	echo "NUM_FTPFILES=          "$NUM_FTPFILES
	echo "NUM_HTTPFILES=         "$NUM_HTTPFILES
	echo "NUM_PNFS=              "$NUM_PNFS
	echo "FILE_SIZE=             "$FILE_SIZE
	echo "FTP_TYPE=              "$FTP_TYPE
	echo "HTTP_TYPE=             "$HTTP_TYPE
	echo "FTP_FILE_PREFIXES=     "$FTP_FILE_PREFIXES
	echo "HTTP_FILE_PREFIXES=    "$HTTP_FILE_PREFIXES
	echo "NUM_FTP_SERVERS=       "$NUM_FTP_SERVERS
	echo "NUM_HTTP_SERVERS=      "$NUM_HTTP_SERVERS
	echo "SFTP_SIMS=             "$SFTP_SIMS
	echo "FTPES_SIMS=             "$FTPES_SIMS
	echo "HTTP_SIMS=             "$HTTP_SIMS
	echo "HTTP_JWT_SIMS=         "$HTTP_JWT_SIMS
	echo "HTTPS_SIMS=            "$HTTPS_SIMS
	echo "HTTPS_SIMS_NO_AUTH=     "$HTTPS_SIMS_NO_AUTH
	echo "HTTPS_JWT_SIMS=         "$HTTPS_JWT_SIMS
	echo ""
}

# Stop and remove all containers including dfc app and simulators
clean_containers() {
	echo "Stopping all containers, dfc app(s) and simulators with name prefix 'dfc_'"
	docker stop $(docker ps -q --filter name=dfc_) &> /dev/null
	echo "Removing all containers, dfc app and simulators with name prefix 'dfc_'"
	docker rm $(docker ps -a -q --filter name=dfc_) &> /dev/null
	docker rm -f $(docker ps -a -q --filter name=oom-certservice-post-processor) &> /dev/null
	echo "Removing unused docker networks with substring 'dfc' in network name"
	docker network rm $(docker network ls -q --filter name=dfc)
	echo ""
}

# Start all simulators in the simulator group
start_simulators() {

	echo "Starting all simulators"
	curdir=$PWD
	cd $SIM_GROUP
	export SIM_GROUP=$SIM_GROUP
	$SIM_GROUP/simulators-start.sh
	cd $curdir
	echo ""
}

# Start the dfc application
start_dfc() {

	if [ $# != 1 ]; then
    	__print_err "need one arg, <dfc-instance-id>"
		exit 1
	fi

	if [ $1 -lt 0 ] || [ $1 -gt $DFC_MAX_IDX ]; then
		__print_err "arg should be 0.."$DFC_MAX_IDX
		exit 1
	fi
	appname=$DFC_APP_BASE$1
	STARTED_DFCS=$STARTED_DFCS"_"$appname"_"

	if [ $START_ARG == "local" ] || [ $START_ARG == "remote" ] ||  [ $START_ARG == "remote-remove" ]; then
		__start_dfc_image $appname $1
	elif [ $START_ARG == "manual-container" ]; then
		__wait_for_container $appname $1
	elif [ $START_ARG == "manual-app" ]; then
		__wait_for_dfc $appname $1
	fi
}

# Configure volume with dfc config, args <dfc-instance-id> <yaml-file-path>
# Not intended to be called directly by test scripts.
__dfc_config() {

	if [ $# != 2 ]; then
    	__print_err "need two args, <dfc-instance-id> <yaml-file-path>"
		exit 1
	fi

	if [ $1 -lt 0 ] || [ $1 -gt $DFC_MAX_IDX ]; then
		__print_err "dfc-instance-id should be 0.."$DFC_MAX_IDX
		exit 1
	fi
	if ! [ -f $2 ]; then
		__print_err "yaml file does not exist: "$2
		exit 1
	fi

	appname=$DFC_APP_BASE$1

	echo "Applying configuration for " $appname " from " $2
	mkdir $(pwd)/../simulator-group/dfc_config_volume/
	cp $2 $(pwd)/../simulator-group/dfc_config_volume/application_config.yaml
}

# Configure volume with dfc app config, args <dfc-instance-id> <yaml-file-path>
dfc_config_app() {
	if [ $START_ARG == "manual-app" ]; then
		echo "Replacing 'mrsim' with 'localhost' in yaml app config"
		sed 's/mrsim/localhost/g' $2 > .tmp_app.yaml
		echo "Replacing 'drsim' with 'localhost' in yaml dmaap config"
		sed 's/drsim/localhost/g' .tmp_app.yaml > .app.yaml
		__dfc_config $1 .app.yaml
	else
		__dfc_config $1 $2
	fi
}

# Stop and remove the dfc app container
kill_dfc() {

	if [ $# != 1 ]; then
    	__print_err "need one arg, <dfc-instance-id>"
		exit 1
	fi

	if [ $1 -lt 0 ] || [ $1 -gt $DFC_MAX_IDX ]; then
		__print_err "arg should be 0.."$DFC_MAX_IDX
		exit 1
	fi
	appname=$DFC_APP_BASE$1

	echo "Killing DFC, instance id: "$1

	if [ $START_ARG == "local" ] || [ $START_ARG == "remote" ] ||  [ $START_ARG == "remote-remove" ]; then
		__docker_stop $appname
		__docker_rm $appname
	elif [ $START_ARG == "manual-container" ]; then
		__wait_for_container_gone $appname
	elif [ $START_ARG == "manual-app" ]; then
		__wait_for_dfc_gone $appname
	fi

	rm -rf $(pwd)/../simulator-group/dfc_config_volume
}

# Stop and remove the DR simulator container
kill_dr() {
	echo "Killing DR sim"
	__docker_stop dfc_dr-sim
	__docker_rm dfc_dr-sim
}

# Stop and remove the DR redir simulator container
kill_drr() {
	echo "Killing DR redir sim"
	__docker_stop dfc_dr-redir-sim
	__docker_rm dfc_dr-redir-sim
}

# Stop and remove the MR simulator container
kill_mr() {
	echo "Killing MR sim"
	__docker_stop dfc_mr-sim
	__docker_rm dfc_mr-sim
}

# Stop and remove the SFTP container, arg: <sftp-instance-id>
kill_sftp() {

	if [ $# != 1 ]; then
    	__print_err "need one arg, <sftp-instance-id>"
		exit 1
	fi

	if [ $1 -lt 0 ] || [ $1 -gt $FTP_MAX_IDX ]; then
		__print_err "arg should be 0.."$FTP_MAX_IDX
		exit 1
	fi
	appname=$SFTP_BASE$1

	echo "Killing SFTP, instance id: "$1

	__docker_stop $appname
	__docker_rm $appname
}

# Stop SFTP container, arg: <sftp-instance-id>
stop_sftp() {

	if [ $# != 1 ]; then
    	__print_err "need one arg, <sftp-instance-id>"
		exit 1
	fi

	if [ $1 -lt 0 ] || [ $1 -gt $FTP_MAX_IDX ]; then
		__print_err "arg should be 0.."$FTP_MAX_IDX
		exit 1
	fi
	appname=$SFTP_BASE$1

	echo "Stopping SFTP, instance id: "$1

	__docker_stop $appname
}

# Starts a stopped SFTP container, arg: <sftp-instance-id>
start_sftp() {

	if [ $# != 1 ]; then
    	__print_err "need one arg, <sftp-instance-id>"
		exit 1
	fi

	if [ $1 -lt 0 ] || [ $1 -gt $FTP_MAX_IDX ]; then
		__print_err "arg should be 0.."$FTP_MAX_IDX
		exit 1
	fi
	appname=$SFTP_BASE$1

	echo "Starting SFTP, instance id: "$1

	__docker_start $appname
}

# Stop and remove the FTPES container, arg: <ftpes-instance-id>
kill_ftpes() {

	if [ $# != 1 ]; then
    	__print_err "need one arg, <ftpes-instance-id>"
		exit 1
	fi

	if [ $1 -lt 0 ] || [ $1 -gt $FTP_MAX_IDX ]; then
		__print_err "arg should be 0.."$FTP_MAX_IDX
		exit 1
	fi
	appname=$FTPES_BASE$1

	echo "Killing FTPES, instance id: "$1

	__docker_stop $appname
	__docker_rm $appname
}

# Stop FTPES container, arg: <ftpes-instance-id>
stop_ftpes() {

	if [ $# != 1 ]; then
    	__print_err "need one arg, <ftpes-instance-id>"
		exit 1
	fi

	if [ $1 -lt 0 ] || [ $1 -gt $FTP_MAX_IDX ]; then
		__print_err "arg should be 0.."$FTP_MAX_IDX
		exit 1
	fi
	appname=$FTPES_BASE$1

	echo "Stopping FTPES, instance id: "$1

	__docker_stop $appname
}

# Starts a stopped FTPES container, arg: <ftpes-instance-id>
start_ftpes() {

	if [ $# != 1 ]; then
    	__print_err "need one arg, <ftpes-instance-id>"
		exit 1
	fi

	if [ $1 -lt 0 ] || [ $1 -gt $FTP_MAX_IDX ]; then
		__print_err "arg should be 0.."$FTP_MAX_IDX
		exit 1
	fi
	appname=$FTPES_BASE$1

	echo "Starting FTPES, instance id: "$1

	__docker_start $appname
}

# Stop and remove the HTTP container, arg: <http-instance-id>
kill_http_https() {

	if [ $# != 1 ]; then
    	__print_err "need one arg, <http-instance-id>"
		exit 1
	fi

	if [ $1 -lt 0 ] || [ $1 -gt $HTTP_MAX_IDX ]; then
		__print_err "arg should be 0.."$HTTP_MAX_IDX
		exit 1
	fi
	appname=$HTTP_HTTPS_BASE$1

	echo "Killing HTTP/HTTPS, instance id: "$1

	__docker_stop $appname
	__docker_rm $appname
}

# Stop HTTP container, arg: <http-instance-id>
stop_http_https() {

	if [ $# != 1 ]; then
    	__print_err "need one arg, <http-instance-id>"
		exit 1
	fi

	if [ $1 -lt 0 ] || [ $1 -gt $HTTP_MAX_IDX ]; then
		__print_err "arg should be 0.."$HTTP_MAX_IDX
		exit 1
	fi
	appname=$HTTP_HTTPS_BASE$1

	echo "Stopping HTTP/HTTPS, instance id: "$1

	__docker_stop $appname
}

# Starts a stopped HTTP container, arg: <http-instance-id>
start_http_https() {

	if [ $# != 1 ]; then
    	__print_err "need one arg, <http-instance-id>"
		exit 1
	fi

	if [ $1 -lt 0 ] || [ $1 -gt $HTTP_MAX_IDX ]; then
		__print_err "arg should be 0.."$HTTP_MAX_IDX
		exit 1
	fi
	appname=$HTTP_HTTPS_BASE$1

	echo "Starting HTTP/HTTPS, instance id: "$1

	__docker_start $appname
}

# Print a variable value from the MR simulator. Arg: <variable-name>
mr_print() {
	if [ $# != 1 ]; then
    	__print_err "need one arg, <sim-param>"
		exit 1
	fi
	echo -e "---- MR sim, \033[1m $1 \033[0m: $(__do_curl http://127.0.0.1:$MR_PORT/$1)"
}

# Print a variable value from the MR https simulator. Arg: <variable-name>
mr_secure_print() {
	if [ $# != 1 ]; then
    	__print_err "need one arg, <sim-param>"
		exit 1
	fi
	echo -e "---- MR sim, \033[1m $1 \033[0m: $(__do_curl https://127.0.0.1:$MR_PORT_SECURE/$1)"
}

# Print a variable value from the DR simulator. Arg: <variable-name>
dr_print() {
	if [ $# != 1 ]; then
    	__print_err "need one arg, <sim-param>"
		exit 1
	fi
	echo -e "---- DR sim, \033[1m $1 \033[0m: $(__do_curl http://127.0.0.1:$DR_PORT/$1)"
}

# Print a variable value from the DR redir simulator. Arg: <variable-name>
drr_print() {
	if [ $# != 1 ]; then
    	__print_err "need one arg, <sim-param>"
		exit 1
	fi
	echo -e "---- DR redir sim, \033[1m $1 \033[0m: $(__do_curl http://127.0.0.1:$DRR_PORT/$1)"
}
# Print a variable value from dfc. Arg: <dfc-instance-id> <variable-name>
dfc_print() {
	if [ $# != 2 ]; then
    	__print_err "need two args, <dfc-instance-id> <dfc-param>"
		exit 1
	fi
	if [ $1 -lt 0 ] || [ $1 -gt $DFC_MAX_IDX ]; then
		__print_err "dfc instance id should be in range 0.."DFC_MAX_IDX
		exit 1
	fi
	localport=$(($DFC_PORT + $1))
	appname=$DFC_APP_BASE$1
	echo -e "---- DFC $appname, \033[1m $2 \033[0m: $(__do_curl http://127.0.0.1:$localport/$2)"
}

# Read a variable value from MR sim and send to stdout. Arg: <variable-name>
mr_read() {
	echo "$(__do_curl http://127.0.0.1:$MR_PORT/$1)"
}

# Read a variable value from MR https sim and send to stdout. Arg: <variable-name>
mr_secure_read() {
	echo "$(__do_curl https://127.0.0.1:$MR_PORT_SECURE/$1)"
}

# Read a variable value from DR sim and send to stdout. Arg: <variable-name>
dr_read() {
	echo "$(__do_curl http://127.0.0.1:$DR_PORT/$1)"
}

# Read a variable value from DR redir sim and send to stdout. Arg: <variable-name>
drr_read() {
	echo "$(__do_curl http://127.0.0.1:$DRR_PORT/$1)"
}


# Sleep. Arg: <sleep-time-in-sec>
sleep_wait() {
	if [ $# != 1 ]; then
		__print_err "need one arg, <sleep-time-in-sec>"
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
	echo ""
}

# Sleep and print dfc heartbeat. Arg: <sleep-time-in-sec>
sleep_heartbeat() {
	if [ $# != 1 ]; then
		__print_err "need one arg, <sleep-time-in-sec>"
		exit 1
	fi
	echo "---- Sleep for " $1 " seconds ----"
	echo ""
	start=$SECONDS
	duration=$((SECONDS-start))
	ctr=0
	rows=0
	while [ $duration -lt $1 ]; do
		if [ $rows -eq 0 ]; then
			tput cuu1
		fi
		rows=0
		echo "  Slept for ${duration} seconds"
		if [ $((ctr%30)) -eq 0 ]; then
			for (( i=0; i<=$DFC_MAX_IDX; i++ )); do
				if [[ $STARTED_DFCS =~ "_"$DFC_APP_BASE$i"_" ]]; then
					let rows=rows+1
					echo "    HB ${DFC_APP_BASE}${i}: $(__do_curl http://127.0.0.1:$(($DFC_PORT+$i))/heartbeat)"
				fi
			done
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
		__var_test "MR" "http://127.0.0.1:$MR_PORT/" $1 "=" $2 $3
	else
		__print_err "Wrong args to mr_equal, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}

mr_secure_equal() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		__var_test "MR" "https://127.0.0.1:$MR_PORT_SECURE/" $1 "=" $2 $3
	else
		__print_err "Wrong args to mr_secure_equal, needs two or three args: <sim-param> <target-value> [ timeout ]"
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
		__var_test "MR" "http://127.0.0.1:$MR_PORT/" $1 ">" $2 $3
	else
		__print_err "Wrong args to mr_greater, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}

mr_secure_greater() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		__var_test "MR" "https://127.0.0.1:$MR_PORT_SECURE/" $1 ">" $2 $3
	else
		__print_err "Wrong args to mr_secure_greater, needs two or three args: <sim-param> <target-value> [ timeout ]"
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
		__var_test "MR" "http://127.0.0.1:$MR_PORT/" $1 "<" $2 $3
	else
		__print_err "Wrong args to mr_less, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}
mr_secure_less() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		__var_test "MR" "https://127.0.0.1:$MR_PORT_SECURE/" $1 "<" $2 $3
	else
		__print_err "Wrong args to mr_secure_less, needs two or three args: <sim-param> <target-value> [ timeout ]"
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
		__var_test "MR" "http://127.0.0.1:$MR_PORT/" $1 "contain_str" $2 $3
	else
		__print_err "Wrong args to mr_contain_str, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}
mr_secure_contain_str() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		__var_test "MR" "https://127.0.0.1:$MR_PORT_SECURE/" $1 "contain_str" $2 $3
	else
		__print_err "Wrong args to mr_secure_contain_str, needs two or three args: <sim-param> <target-value> [ timeout ]"
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
		__var_test "DR" "http://127.0.0.1:$DR_PORT/" $1 "=" $2 $3
	else
		__print_err "Wrong args to dr_equal, needs two or three args: <sim-param> <target-value> [ timeout ]"
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
		__var_test "DR" "http://127.0.0.1:$DR_PORT/" $1 ">" $2 $3
	else
		__print_err "Wrong args to dr_greater, needs two or three args: <sim-param> <target-value> [ timeout ]"
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
		__var_test "DR" "http://127.0.0.1:$DR_PORT/" $1 "<" $2 $3
	else
		__print_err "Wrong args to dr_less, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}

# Tests if a variable value in the DR simulator contains the target string and and optional timeout.
# Arg: <variable-name> <target-value> - This test set pass or fail depending on if the variable contains
# the target or not.
# Arg: <variable-name> <target-value> <timeout-in-sec>  - This test waits up to the timeout seconds
# before setting pass or fail depending on if the variable value contains the target
# value or not.
dr_contain_str() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		__var_test "DR" "http://127.0.0.1:$DR_PORT/" $1 "contain_str" $2 $3
	else
		__print_err "Wrong args to dr_contain_str, needs two or three args: <sim-param> <target-value> [ timeout ]"
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
		__var_test "DR REDIR" "http://127.0.0.1:$DRR_PORT/" $1 "=" $2 $3
	else
		__print_err "Wrong args to drr_equal, needs two or three args: <sim-param> <target-value> [ timeout ]"
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
		__var_test "DR REDIR" "http://127.0.0.1:$DRR_PORT/" $1 ">" $2 $3
	else
		__print_err "Wrong args to drr_greater, needs two or three args: <sim-param> <target-value> [ timeout ]"
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
		__var_test "DR REDIR" "http://127.0.0.1:$DRR_PORT/" $1 "<" $2 $3
	else
		__print_err "Wrong args to drr_less, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}

# Tests if a variable value in the DR redir simulator contains the target string and and optional timeout.
# Arg: <variable-name> <target-value> - This test set pass or fail depending on if the variable contains
# the target or not.
# Arg: <variable-name> <target-value> <timeout-in-sec>  - This test waits up to the timeout seconds
# before setting pass or fail depending on if the variable value contains the target
# value or not.
drr_contain_str() {
	if [ $# -eq 2 ] || [ $# -eq 3 ]; then
		__var_test "DR REDIR" "http://127.0.0.1:$DRR_PORT/" $1 "contain_str" $2 $3
	else
		__print_err "Wrong args to drr_contain_str, needs two or three args: <sim-param> <target-value> [ timeout ]"
	fi
}

#Test if a variable in the DFC contains a substring. Arg: <dfc-index> <variable-name> <substring-in-quotes>
dfc_contain_str() {
	if [ $# -eq 3 ]; then
		if [ $1 -lt 0 ] || [ $1 -gt $DFC_MAX_IDX ]; then
			__print_err "arg should be 0.."$DFC_MAX_IDX
			exit 1
		fi
		appname=$DFC_APP_BASE$1
		localport=$(($DFC_PORT + $1))
		echo -e "---- DFC test criteria: $appname \033[1m ${2} \033[0m contains: ${3} ----"
		((RES_TEST++))
		result="$(__do_curl http://127.0.0.1:$localport/${2})"
		if [[ $result =~ $3 ]]; then
			((RES_PASS++))
			echo -e "----  \033[32m\033[1mPASS\033[0m - Test criteria met"
		else
			((RES_FAIL++))
			echo -e "----  \033[31m\033[1mFAIL\033[0m - Target '${3}' not reached, result = ${result} ----"
		fi
	else
		echo "Wrong args to dfc_contain_str, needs three arg: <dfc-index> <dfc-variable> <str>"
		exit 1
	fi
}

# Store all dfc app and simulators log to the test case log dir. All logs gets a prefix to
# separate logs stored at different steps in the test script. Arg: <tc-id> <log-prefix>
store_logs() {
	if [ $# != 1 ]; then
    	__print_err "need one arg, <file-prefix>"
		exit 1
	fi
	echo "Storing all container logs and dfc app log using prefix: "$1
	if ! [ $START_ARG == "manual-app" ]; then
		for (( i=0; i<=$DFC_MAX_IDX; i++ )); do
			appname=$DFC_APP_BASE$i
			tmp=$(docker ps | grep $appname)
			if ! [ -z "$tmp" ]; then   #Only stored logs from running DFC apps
				docker cp $appname:/var/log/ONAP/application.log $TESTLOGS/$ATC/${1}_${appname}_application.log
				docker logs $appname > $TESTLOGS/$ATC/$1_$appname-docker.log 2>&1
			fi
		done
	fi
	docker logs dfc_mr-sim > $TESTLOGS/$ATC/$1_dfc_mr-sim-docker.log 2>&1
	docker logs dfc_dr-sim > $TESTLOGS/$ATC/$1_dfc_dr-sim-docker.log 2>&1
	docker logs dfc_dr-redir-sim > $TESTLOGS/$ATC/$1_dfc_dr-redir-sim-docker.log 2>&1

	for (( i=0; i<=$FTP_MAX_IDX; i++ )); do
		appname=$SFTP_BASE$i
		docker logs $appname > $TESTLOGS/$ATC/${1}_${appname}.log 2>&1
		appname=$FTPES_BASE$i
		docker logs $appname > $TESTLOGS/$ATC/${1}_${appname}.log 2>&1
	done

	for (( i=0; i<=$HTTP_MAX_IDX; i++ )); do
		appname=$HTTP_HTTPS_BASE$i
		docker logs $appname > $TESTLOGS/$ATC/${1}_${appname}.log 2>&1
	done

}
# Check the dfc application log, for all dfc instances, for WARN and ERR messages and print the count.
check_dfc_logs() {
	for (( i=0; i<=$DFC_MAX_IDX; i++ )); do
		appname=$DFC_APP_BASE$i
		tmp=$(docker ps | grep $appname)
		if ! [ -z "$tmp" ]; then  #Only check logs for running dfc_apps
			_check_dfc_log $appname
		fi
	done
}

# Check dfc app log for one dfc instance, arg <dfc-app-name>
_check_dfc_log() {
	echo "Checking $1 log $DFC_LOGPATH for WARNINGs and ERRORs"
	foundentries=$(docker exec -it $1 grep WARN /var/log/ONAP/application.log | wc -l)
	if [ $? -ne  0 ];then
		echo "  Problem to search $1 log $DFC_LOGPATH"
	else
		if [ $foundentries -eq 0 ]; then
			echo "  No WARN entries found in $1 log $DFC_LOGPATH"
		else
			echo -e "  Found \033[1m"$foundentries"\033[0m WARN entries in $1 log $DFC_LOGPATH"
		fi
	fi
	foundentries=$(docker exec -it $1 grep ERR $DFC_LOGPATH | wc -l)
	if [ $? -ne  0 ];then
		echo "  Problem to search $1 log $DFC_LOGPATH"
	else
		if [ $foundentries -eq 0 ]; then
			echo "  No ERR entries found in $1 log $DFC_LOGPATH"
		else
			echo -e "  Found \033[1m"$foundentries"\033[0m ERR entries in $1 log $DFC_LOGPATH"
		fi
	fi
}

print_all() {

	echo "---- DFC and all sim variables"

	for (( i=0; i<=$DFC_MAX_IDX; i++ )); do
		appname=$DFC_APP_BASE$i
		tmp=$(docker ps | grep $appname)
		if ! [ -z "$tmp" ]; then  #Only check running dfc_apps
			dfc_print $i status
		fi
	done


	mr_print tc_info
	mr_print status
	mr_print execution_time
	mr_print groups
	mr_print changeids
	mr_print fileprefixes
	mr_print exe_time_first_poll
	mr_print groups/exe_time_first_poll
	mr_print ctr_requests
	mr_print groups/ctr_requests
	mr_print ctr_responses
	mr_print groups/ctr_responses
	mr_print ctr_files
	mr_print groups/ctr_files
	mr_print ctr_unique_files
	mr_print groups/ctr_unique_files
	mr_print groups/ctr_events
	mr_print ctr_events
	mr_print ctr_unique_PNFs
	mr_print groups/ctr_unique_PNFs

	dr_print tc_info
	dr_print execution_time
	dr_print feeds
	dr_print ctr_publish_query
	dr_print feeds/ctr_publish_query
	dr_print ctr_publish_query_bad_file_prefix
	dr_print feeds/ctr_publish_query_bad_file_prefix
	dr_print ctr_publish_query_published
	dr_print feeds/ctr_publish_query_published
	dr_print ctr_publish_query_not_published
	dr_print feeds/ctr_publish_query_not_published
	dr_print ctr_publish_req
	dr_print feeds/ctr_publish_req
	dr_print ctr_publish_req_bad_file_prefix
	dr_print feeds/ctr_publish_req_bad_file_prefix
	dr_print ctr_publish_req_redirect
	dr_print feeds/ctr_publish_req_redirect
	dr_print ctr_publish_req_published
	dr_print feeds/ctr_publish_req_published
	dr_print ctr_published_files
	dr_print feeds/ctr_published_files
	dr_print ctr_double_publish
	dr_print feeds/ctr_double_publish

	drr_print tc_info
	drr_print execution_time
	drr_print feeds
	drr_print ctr_publish_requests
	drr_print feeds/ctr_publish_requests
	drr_print ctr_publish_requests_bad_file_prefix
	drr_print feeds/ctr_publish_requests_bad_file_prefix
	drr_print ctr_publish_responses
	drr_print feeds/ctr_publish_responses
	drr_print dwl_volume
	drr_print feeds/dwl_volume
	drr_print time_lastpublish
	drr_print feeds/time_lastpublish
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
 		echo -e "\033[31m\033[1m ___  ___ ___ ___ ___ _____   ___ _   ___ _   _   _ ___ ___ \033[0m"
 		echo -e "\033[31m\033[1m/ __|/ __| _ \_ _| _ \_   _| | __/_\ |_ _| | | | | | _ \ __|\033[0m"
		echo -e "\033[31m\033[1m\__ \ (__|   /| ||  _/ | |   | _/ _ \ | || |_| |_| |   / _| \033[0m"
 		echo -e "\033[31m\033[1m|___/\___|_|_\___|_|   |_|   |_/_/ \_\___|____\___/|_|_\___|\033[0m"
	elif [ $total != $RES_TEST ]; then
		echo -e "\033[1mTotal number of tests does not match the sum of passed and failed tests. Check the script....\033[0m"
		echo -e "\033[31m\033[1m ___  ___ ___ ___ ___ _____   ___ _   ___ _   _   _ ___ ___ \033[0m"
		echo -e "\033[31m\033[1m/ __|/ __| _ \_ _| _ \_   _| | __/_\ |_ _| | | | | | _ \ __|\033[0m"
		echo -e "\033[31m\033[1m\__ \ (__|   /| ||  _/ | |   | _/ _ \ | || |_| |_| |   / _| \033[0m"
 		echo -e "\033[31m\033[1m|___/\___|_|_\___|_|   |_|   |_/_/ \_\___|____\___/|_|_\___|\033[0m"
	elif [ $RES_PASS = $RES_TEST ]; then
		echo -e "All tests \033[32m\033[1mPASS\033[0m"
		echo -e "\033[32m\033[1m  ___  _   ___ ___ \033[0m"
		echo -e "\033[32m\033[1m | _ \/_\ / __/ __| \033[0m"
		echo -e "\033[32m\033[1m |  _/ _ \\__ \__ \\ \033[0m"
		echo -e "\033[32m\033[1m |_|/_/ \_\___/___/ \033[0m"
		echo ""

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
		echo -e "\033[31m\033[1m  ___ _   ___ _    \033[0m"
		echo -e "\033[31m\033[1m | __/_\ |_ _| |   \033[0m"
		echo -e "\033[31m\033[1m | _/ _ \ | || |__ \033[0m"
		echo -e "\033[31m\033[1m |_/_/ \_\___|____|\033[0m"
		echo ""
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
