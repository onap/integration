#!/usr/bin/env bash

set -euo pipefail

COMPOSE_FILE_NAME=docker-compose.yml
NETOPEER_CONTAINER_NAME=netopeer
SIMULATOR_CONTAINER_NAME=pnf-simulator
SIMULATOR_PORT=5000
SIMULATOR_START_URL=http://localhost:$SIMULATOR_PORT/simulator/start
SIMULATOR_STOP_URL=http://localhost:$SIMULATOR_PORT/simulator/stop
SIMULATOR_STATUS_URL=http://localhost:$SIMULATOR_PORT/simulator/status
RUNNING_COMPOSE_CONFIG=$COMPOSE_FILE_NAME

function main(){

    COMMAND=${1:-"help"}

    case $COMMAND in
    	"compose")
            compose $2 $3 $4 $5 $6 $7 $8;;
             #IPGW, #IPSUBNET, #I, #IPVES, #IPPNFSIM, #IPFTP, #IPSFTP,
        "build")
            build_image;;
        "start")
            start $COMPOSE_FILE_NAME;;
        "stop")
            stop;;
        "run-simulator")
            run_simulator;;
        "stop-simulator")
            stop_simulator;;
        "status")
             get_status;;
        "clear-logs")
             clear_logs;;
        *)
            print_help;;
    esac
}

function compose(){
	#creating custom docker-compose based on IP arguments
	#creting config.json by injecting the same IP

	export IPGW=$1
	export IPSUBNET=$2
	export I=$3
	export IPVES=$4
	export IPPNFSIM=$5
	export IPFTPS=$6
	export IPSFTP=$7

	#will insert $I to distinguish containers, networks properly
	#docker compose cannot substitute these, as they are keys, not values.
	envsubst < docker-compose-template.yml > docker-compose-temporary.yml
	#variable substitution
	docker-compose -f docker-compose-temporary.yml config > docker-compose.yml
	rm docker-compose-temporary.yml

	cd files
	./prepare-ROP-files.sh
	cd -

	set_vsftpd_file_owner

	write_config $IPVES $IPFTPS $IPSFTP

}

function build_image(){
    if [ -f pom.xml ]; then
        mvn clean package docker:build
    else
        echo "pom.xml file not found"
        exit 1
    fi
}

function set_vsftpd_file_owner() {
    sudo chown root ./config/vsftpd_ssl.conf
}


function write_config(){
	#building a YML file for usage in Java
	echo "---" > config/config.yml
	echo "configuration:" >> config/config.yml
	echo "  vesip: $1" >> config/config.yml
	echo "  ipftps: $2" >> config/config.yml
	echo "  ipsftp: $3" >> config/config.yml
}

function start(){

    if [[ $(running_containers) ]]; then
        echo "Simulator containers are already up"
    else
        echo "Starting simulator containers using netconf model specified in config/netconf.env"
        set_vsftpd_file_owner
        archive_logs
        docker-compose -f $1 up -d
        RUNNING_COMPOSE_CONFIG=$1
    fi
}

function running_containers(){
   docker-compose -f $COMPOSE_FILE_NAME ps -q
}

function stop(){

    if [[ $(running_containers) ]]; then
        docker-compose -f $RUNNING_COMPOSE_CONFIG down
        docker-compose -f $RUNNING_COMPOSE_CONFIG rm
    else
        echo "Simulator containers are already down"
    fi
}

function run_simulator(){

cat << EndOfMessage
Simulator response:
$(curl -s -X POST -H "Content-Type: application/json" -H "X-ONAP-RequestID: 123" -H "X-InvocationID: 456" -d @config/$CONFIG_JSON $SIMULATOR_START_URL)
EndOfMessage
}

function stop_simulator(){
cat << EndOfMessage
Simulator response:
$(curl -s -X POST $SIMULATOR_STOP_URL)
EndOfMessage
}

function get_status(){

    if [[ $(running_containers) ]]; then
        print_status
    else
        echo "Simulator containers are down"
    fi
}

function print_status(){
cat << EndOfMessage
$(docker-compose -f $RUNNING_COMPOSE_CONFIG ps)

Simulator response:
$(curl -s -X GET $SIMULATOR_STATUS_URL)
EndOfMessage
}

function print_help(){
cat << EndOfMessage
Available options:
build - locally builds simulator image from existing code
start - starts simulator and netopeer2 containers using remote simulator image and specified model name
compose - customize the docker-compose and configuration based on arguments
run-simulator - starts sending PNF registration messages with parameters specified in config.json
stop-simulator - stop sending PNF registration messages
stop - stops both containers
status - prints simulator status
clear-logs - deletes log folder

Starting simulation:
- Setup the instance of this simulator by:
  - ./simulator.sh compose IPGW IPSUBNET I IPVES IPPNFSIM IPFTPS IPSFTP
	where Gw and subnet will be used for docker network
	where I is the integer suffix to differentiate instances
	where IPVES is the address of the VES collector
	where IPPNFSIM, IPFTPS, IPSFTP are the addresses for containers
	e.g. ./simulator.sh compose 10.11.0.65 10.11.0.64 3 10.11.0.2 10.11.0.66 10.11.0.67 10.11.0.68

- Setup environment with "./simulator.sh start". It will download required docker images from the internet and run them on docker machine
- To start the simulation use "./simulator.sh run-simulator", which will start sending PNF registration messages with parameters specified in config.json    {TODO, might not be needed}

To stop simulation use "./simulator.sh stop-simulator" command. To check simulator's status use "./simulator.sh status".
If you want to change message parameters simply edit config.json, then start the simulation with "./simulator.sh run-simulator" again
Logs are written to logs/pnf-simulator.log.

If you change the source code you have to rebuild image with "./simulator.sh build" and run "./simulator.sh start" again
EndOfMessage
}

function archive_logs(){

    if [ -d logs ]; then
        echo "Moving log file to archive"
        DIR_PATH=logs/archive/simulator[$(timestamp)]
        mkdir -p $DIR_PATH
        if [ -f logs/pnfsimulator.log ]; then
           mv logs/pnfsimulator.log $DIR_PATH
        fi

        if [ -f logs/*.xml ]; then
            mv logs/*.xml $DIR_PATH
        fi

    else
        mkdir logs
    fi
}

function clear_logs(){

    if [[ $(running_containers) ]]; then
        echo "Cannot delete logs when simulator is running"
    else
         rm -rf logs
    fi
}

function timestamp(){
  date "+%Y-%m-%d_%T"
}

main $@