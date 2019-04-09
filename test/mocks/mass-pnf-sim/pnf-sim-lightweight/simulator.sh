#!/usr/bin/env bash

set -euo pipefail

COMPOSE_FILE_NAME=docker-compose.yml
NETOPEER_CONTAINER_NAME=netopeer
SIMULATOR_CONTAINER_NAME=pnf-simulator
SIMULATOR_PORT=5000

SIMULATOR_BASE=http://localhost:$SIMULATOR_PORT/simulator/
SIMULATOR_START_URL=$SIMULATOR_BASE/start
SIMULATOR_STOP_URL=$SIMULATOR_BASE/stop
SIMULATOR_STATUS_URL=$SIMULATOR_BASE/status

RUNNING_COMPOSE_CONFIG=$COMPOSE_FILE_NAME

function main(){

    COMMAND=${1:-"help"}

    case $COMMAND in
    	"compose")
            compose $2 $3 $4 $5 $6 $7 $8 $9 "${10}" "${11}" ;;
             #IPGW, #IPSUBNET, #I, #IPVES, #IPPNFSIM, #IPFILESERVER, #PORTSFTP, #PORTFTPS, #IPFTPS, #IPSFTP
        "build")
            build_image;;
        "start")
            start $COMPOSE_FILE_NAME;;
        "stop")
            if [[ -z ${2+x} ]]
            then
               echo "Error: action 'stop' requires the instance identifier"
               exit
            fi
            stop $2;;
        "run-simulator")
            run_simulator;;
        "trigger-simulator")
            trigger_simulator;;
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


function get_pnfsim_ip() {

	export IPPNFSIM=$(cat ./config/config.yml | grep ippnfsim | awk -F'[ ]' '{print $2}')
	echo "PNF-Sim IP: " $IPPNFSIM
	
	export SIMULATOR_BASE=http://$IPPNFSIM:$SIMULATOR_PORT/simulator/
	export SIMULATOR_START_URL=$SIMULATOR_BASE/start
	export SIMULATOR_STOP_URL=$SIMULATOR_BASE/stop
	export SIMULATOR_STATUS_URL=$SIMULATOR_BASE/status
}

function compose(){
	#creating custom docker-compose based on IP arguments
	#creting config.json by injecting the same IP

	export IPGW=$1
	export IPSUBNET=$2
	export I=$3
	export IPVES=$4
	export IPPNFSIM=$5
	export IPFILESERVER=$6
	export PORTSFTP=$7
	export PORTFTPS=$8
	export IPFTPS=$9
	export IPSFTP=${10}

	#will insert $I to distinguish containers, networks properly
	#docker compose cannot substitute these, as they are keys, not values.
	envsubst < docker-compose-template.yml > docker-compose-temporary.yml
	#variable substitution
	docker-compose -f docker-compose-temporary.yml config > docker-compose.yml
	rm docker-compose-temporary.yml

	./ROP_file_creator.sh $I &

	set_vsftpd_file_owner

	write_config $IPVES $IPFILESERVER $PORTSFTP $PORTFTPS $IPPNFSIM

}

function build_image(){
    if [ -f pom.xml ]; then
        mvn clean package docker:build -Dcheckstyle.skip
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
	echo "urlves: $1" > config/config.yml
	echo "urlsftp: sftp://onap:pano@$2:$3" >> config/config.yml
	echo "urlftps: ftps://onap:pano@$2:$4" >> config/config.yml
	echo "ippnfsim: $5" >> config/config.yml
	echo "defaultfileserver: sftp" >> config/config.yml
}

function start(){

	get_pnfsim_ip
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
	get_pnfsim_ip
    kill $(ps -ef | grep "[.]/ROP_file_creator.sh $1" | head -n 1 | awk '{print $2}')

    if [[ $(running_containers) ]]; then
        docker-compose -f $RUNNING_COMPOSE_CONFIG down
        docker-compose -f $RUNNING_COMPOSE_CONFIG rm
    else
        echo "Simulator containers are already down"
    fi
}

function trigger_simulator(){
get_pnfsim_ip
cat << EndOfMessage
Simulator response:
$(curl -s -X POST -H "Content-Type: application/json" -H "X-ONAP-RequestID: 123" -H "X-InvocationID: 456" -d @config/config.json $SIMULATOR_START_URL)
EndOfMessage
}

function run_simulator(){
get_pnfsim_ip
cat << EndOfMessage
Simulator response:
$(curl -s -X POST -H "Content-Type: application/json" -H "X-ONAP-RequestID: 123" -H "X-InvocationID: 456" -d @config/$CONFIG_JSON $SIMULATOR_START_URL)
EndOfMessage
}

function stop_simulator(){
get_pnfsim_ip
cat << EndOfMessage
Simulator response:
$(curl -s -X POST $SIMULATOR_STOP_URL)
EndOfMessage
}

function get_status(){
	get_pnfsim_ip
    if [[ $(running_containers) ]]; then
        print_status
    else
        echo "Simulator containers are down"
    fi
}

function print_status(){
get_pnfsim_ip
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
trigger-simulator - start monitoring the ROP files and report periodically
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