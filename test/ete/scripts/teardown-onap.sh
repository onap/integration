#!/bin/bash -x

full_deletion=false

usage() { echo "Usage: $0 [-n <string>] [-r]" 1>&2; exit 1; }

while getopts ":rqn:" o; do
    case "${o}" in

        r)
            echo "The following command will delete all information relating to onap within your enviroment"
            read -p "Are you certain this is what you want? (type y to confirm):" answer

            if [ $answer = "y" ] || [ $answer = "Y" ] || [ $answer = "yes" ] || [ $answer = "Yes"]; then
                echo "This may delete the work of other colleages within the same enviroment"
                read -p "Are you certain this is what you want? (type y to confirm):" answer2
                
                if [ $answer2 = "y" ] || [ $answer2 = "Y" ] || [ $answer2 = "yes" ] || [ $answer2 = "Yes"]; then
                    full_deletion=true
                else 
                    echo "Ending program"
                    exit 1
                fi
            else 
                echo "Ending program"
                exit 1
            fi
            ;;
        q)
            full_deletion=true
            ;;
        n)
            install_name=${OPTARG}
            ;;

        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

source $WORKSPACE/test/ete/scripts/install_openstack_cli.sh

if [ "$full_deletion" = true ];then 
    echo "Commencing delete, press CRTL-C to stop"
    sleep 10

    #delete all instances
    openstack server delete $(openstack server list -c ID -f value)
    sleep 1

    #miscellaneous cleanup
    openstack floating ip delete $(openstack floating ip list -c ID -f value)
    sleep 1

    ROUTERS=$(openstack router list -c ID -f value)
    echo $ROUTERS
    for ROUTER in $ROUTERS; do
        echo $ROUTER;
        PORTS=$(openstack router show $ROUTER  -c "interfaces_info" -f "value" | jq -r '.[].port_id')
        for PORT in $PORTS; do
            openstack router remove port $ROUTER $PORT
        done
        openstack router delete $ROUTER
    done

    openstack port delete $(openstack port list -f value -c ID)
    openstack volume delete $(openstack volume list -f value -c ID)

    #delete all except "default" security group
    SECURITY_GROUPS=$(openstack security group list -c ID -f value | grep -v default)
    openstack security group delete $SECURITY_GROUPS
    sleep 1


    #Delete all existing stacks
    STACKS=$(openstack stack list -c "Stack Name" -f value)

    if [ ! -z "${STACKS}" ]; then
        openstack stack delete -y $STACKS
        for STACK in ${STACKS}; do
            until [ "DELETE_IN_PROGRESS" != "$(openstack stack show -c stack_status -f value $STACK)" ]; do
                sleep 2
            done
        done
    else
        echo "No existing stacks to delete."
    fi

else 
    #Restrained teardown 
    echo "Restrained teardown"

    STACK=$install_name
    
    STATUS=$(openstack stack check $STACK)
    
    if [ "Stack not found: $install_name" != "$STATUS" ]; then
        openstack stack delete $STACK
        
        until [ "DELETE_IN_PROGRESS" != "$(openstack stack show -c stack_status -f value $STACK)" ]; do
        sleep 2
        done
    else
        echo "No existing stack with the name $install_name."
    fi
fi