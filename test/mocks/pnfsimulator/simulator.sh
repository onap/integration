#!/usr/bin/env bash

set -euo pipefail

CONTAINER_NAME=pnf-simulator
CONFIG_FILE_PATH=/config/body.json
SIMULATOR_DOCKER_HUB=nexus3.onap.org:10003/onap
<<<<<<< HEAD
SIMULATOR_TAG=1.1.0-SNAPSHOT-latest
=======
SIMULATOR_TAG=1.0.0-SNAPSHOT-latest
>>>>>>> d77cb63... Changing docker image tag

function main(){

    COMMAND=${1:-"help"}

    case $COMMAND in
        "build")
            build_image;;
        "start")
            start_simulator $2 $CONFIG_FILE_PATH $SIMULATOR_DOCKER_HUB/pnf-simulator:$SIMULATOR_TAG;;
        "start-dev")
            start_simulator $2 $CONFIG_FILE_PATH pnf-simulator:$SIMULATOR_TAG;;
        "stop")
            stop_simulator;;
        "status")
            print_status;;
        "logs")
            get_logs;;
        "help")
            print_help;;
        *)
            print_help;;
    esac
}

function build_image(){
    if [ -f pom.xml ]; then
        mvn clean package
    else
        echo "pom.xml file not found"
        exit 1
    fi
}

function start_simulator(){

    stop_and_remove_container || true

    if [ $(docker run -d --name $CONTAINER_NAME -v $(pwd):/config -e VES_ADDRESS=$1 -e CONFIG_FILE_PATH=$2 $3) > /dev/null ]; then
        echo "Simulator started"
    else
        echo "Failed to start simulator"
    fi
}

function stop_and_remove_container(){
    docker rm -f $CONTAINER_NAME 1> /dev/null
}

function stop_simulator(){
    if [ $(docker kill $CONTAINER_NAME) > /dev/null ]; then
        echo "Simulator stopped"
    else
        echo "Failed to stop simulator"
    fi

}

function print_status(){
cat << EndOfMessage

Simulator container status:

$(docker ps -a -f name=$CONTAINER_NAME)

EndOfMessage
}

function print_help(){
cat << EndOfMessage

Available options:
build - locally builds simulator image from existing code
start <ves-url> - starts simulator using remote docker image and connects to given VES server
start-dev <ves-url> - starts simulator using local docker image and connects to given VES server
stop - stops simulator
status - prints container status
logs - prints logs
help - prints this message

Starting simulation:
Use "./simulator.sh start". It will download required docker image from the internet and start simulator using body.json file

To stop simulation use "./simulator.sh stop" command. To check simulator's status use "./simulator.sh status".
If you want to change message parameters simply edit body.json file then run simulator again.

FOR DEVELOPERS
1. Build local simulator image using "./simulator.sh build"
2. Run simulation with "./simulator.sh start-dev"

If you change the source code you have to rebuild image with "./simulator.sh build" and run  "./simulator.sh start-dev" again

EndOfMessage
}

function get_logs(){
    docker logs --tail all $CONTAINER_NAME
}

main $@