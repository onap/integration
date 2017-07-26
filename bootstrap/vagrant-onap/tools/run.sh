#!/bin/bash

case $1 in
    "all_in_one" )
        export DEPLOY_MODE='all-in-one' ;;
    "dns" | "mr" | "sdc" | "aai" | "mso" | "robot" | "vid" | "sdnc" | "portal" | "dcae" | "policy" | "appc" )
        export DEPLOY_MODE='individual' ;;
    "testing" )
        export DEPLOY_MODE='testing'
        export TEST_SUITE=${2:-*}
        export TEST_CASE=${3:-*}

        rm -rf ../opt/
        rm -rf ~/.m2/;;
esac
vagrant destroy -f $1
vagrant up $1
