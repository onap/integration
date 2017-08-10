#!/bin/bash

usage ()
{
cat <<EOF
Usage: run.sh [-y] [-h] Command
Optional arguments:
    -y
        Skips warning prompt.
    -h
        Shows help about this program.
    -s <suite>
        Test suite to use in testing mode.
    -c <case>
        Test case to use in testing mode.
Commands:
    all_in_one  Deploy in all-in-one mode.
    dns|mr|sdc|aai|mso|robot|vid|sdnc|portal|dcae|policy|appc  Deploy chosen service.
    testing  Deploy in testing mode.
EOF
}

run=false
test_suite="*"
test_case="*"

COMMAND=${@: -1}

while getopts "yhs:c:" OPTION; do
  case "$OPTION" in
    y)
      run=true
      ;;
    s)
      if [ "$COMMAND" != "testing" ] ; then
        echo "Test suite should only be specified in testing mode."
        echo "./run.sh -h for usage."
        exit 0
      fi
      test_suite=$OPTARG
      ;;
    c)
      if [ "$COMMAND" != "testing" ] ; then
        echo "Test case should only be specified in testing mode."
        echo "./run.sh -h for usage."
        exit 0
      fi
      test_case=$OPTARG
      ;;
    h)
      usage
      exit 0
      ;;
  esac
done

case $COMMAND in
    "all_in_one" )
        export DEPLOY_MODE='all-in-one'
        ;;
    "dns" | "mr" | "sdc" | "aai" | "mso" | "robot" | "vid" | "sdnc" | "portal" | "dcae" | "policy" | "appc" )
        export DEPLOY_MODE='individual'
        ;;
    "testing" )
        export DEPLOY_MODE='testing'
        if  [ "$run" == false ] ; then
          while true ; do
            echo "Warning: This test script will delete the contents of ../opt/ and ~/.m2."
            read -p "Would you like to continue? [y]es/[n]o: " yn
            case $yn in
              [Yy]*)
                break
                ;;
              [Nn]*)
                echo "Exiting."
                exit 0
                ;;
            esac
          done
        fi

        export TEST_SUITE=$test_suite
        export TEST_CASE=$test_case
        rm -rf ../opt/
        rm -rf ~/.m2/
        ;;
    * )
        usage
        exit 1
esac

vagrant destroy -f $1
vagrant up $1
