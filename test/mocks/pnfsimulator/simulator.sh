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
        "build")
            build_image;;
        "start")
            start $COMPOSE_FILE_NAME;;
        "start-dev")
            start_netconf_server $COMPOSE_FILE_NAME;;
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

function build_image(){
    if [ -f pom.xml ]; then
        mvn clean package docker:build
    else
        echo "pom.xml file not found"
        exit 1
    fi
}

function set_vsftpd_file_owner() {
    sudo chown root ./ftpes/vsftpd/configuration/vsftpd_ssl.conf
}

function start_netconf_server() {
    set_vsftpd_file_owner
    docker-compose -f $1 up -d $NETOPEER_CONTAINER_NAME
    echo
    echo "NETCONF server container's logs:"
    docker exec $NETOPEER_CONTAINER_NAME /bin/bash -c "sysrepoctl --install --yang=/netconf/\$NETCONF_MODEL.yang --owner=netconf:nogroup --permissions=777"
    docker exec $NETOPEER_CONTAINER_NAME /bin/bash -c "sysrepocfg --import=/netconf/\$NETCONF_MODEL.data.xml --datastore=startup --format=xml --level=3 \$NETCONF_MODEL"
    docker exec -d $NETOPEER_CONTAINER_NAME /bin/bash -c "/opt/dev/sysrepo/build/examples/application_example \$NETCONF_MODEL"
    echo
}

function start(){

    if [[ $(running_containers) ]]; then
        echo "Simulator containers are already up"
    else
        echo "Starting simulator containers using netconf model specified in config/netconf.env"
        set_vsftpd_file_owner
        archive_logs
        start_netconf_server $1
        docker-compose -f $1 up -d $SIMULATOR_CONTAINER_NAME
        RUNNING_COMPOSE_CONFIG=$1
    fi
}

function running_containers(){
   docker-compose -f $COMPOSE_FILE_NAME ps -q
}

function stop(){

    if [[ $(running_containers) ]]; then
        docker-compose -f $RUNNING_COMPOSE_CONFIG down
    else
        echo "Simulator containers are already down"
    fi
}

function run_simulator(){
cat << EndOfMessage
Simulator response:
$(curl -s -X POST -H "Content-Type: application/json" -H "X-ONAP-RequestID: 123" -H "X-InvocationID: 456" -d @config/config.json $SIMULATOR_START_URL)
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
start-dev - starts only  netopeer2 container
run-simulator - starts sending PNF registration messages with parameters specified in config.json
stop-simulator - stop sending PNF registration messages
stop - stops both containers
status - prints simulator status
clear-logs - deletes log folder

Starting simulation:

- Setup environment with "./simulator.sh start". It will download required docker images from the internet and run them on docker machine
- To start the simulation use "./simulator.sh run-simulator", which will start sending PNF registration messages with parameters specified in config.json

To stop simulation use "./simulator.sh stop-simulator" command. To check simulator's status use "./simulator.sh status".
If you want to change message parameters simply edit config.json, then start the simulation with "./simulator.sh run-simulator" again
Logs are written to logs/pnf-simulator.log. After each "start/start-dev" old log files are moved to the archive

FOR DEVELOPERS
1. Build local simulator image using "./simulator.sh build"
2. Run containers with "./simulator.sh start-dev"

If you change the source code you have to rebuild image with "./simulator.sh build" and run "./simulator.sh start/start-dev" again
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