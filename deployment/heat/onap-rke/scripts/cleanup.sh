#!/bin/bash

IFS='
'

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
	echo "Usage: ./cleanup.sh namespace deployment onap_component_name"
	exit 1
fi

COMPONENT=`echo "$1" | tr '[:upper:]' '[:lower:]'`
NAMESPACE=`echo "$2" | tr '[:upper:]' '[:lower:]'`
DEPLOYMENT=`echo "$3" | tr '[:upper:]' '[:lower:]'`

if [ $COMPONENT == "dcae" ]; then
        ARRAY=(`kubectl get replicasets -n $NAMESPACE | grep $DEPLOYMENT- | awk '{print $1}'`)
	for i in ${ARRAY[*]}; do
		kubectl delete replicaset -n $NAMESPACE $i
	done

	ARRAY=(`kubectl get services -n $NAMESPACE | grep -e ^xdcae | awk '{print $1}'`)
	for i in ${ARRAY[*]}; do
		kubectl delete service -n $NAMESPACE $i
	done

	ARRAY=(`kubectl get services -n $NAMESPACE | grep -e ^holmes | awk '{print $1}'`)
	for i in ${ARRAY[*]}; do
		kubectl delete service -n $NAMESPACE $i
	done
fi

if [ $COMPONENT == "sdc" ]; then
        for keyspace in sdctitan sdcrepository sdcartifact sdccomponent sdcaudit; do
	        kubectl -n $NAMESPACE exec dev-cassandra-cassandra-0 -- cqlsh -u cassandra -p cassandra -e "drop keyspace ${keyspace}"
        done
fi

if [ $COMPONENT == "so" ]; then
        for database in camundabpmn catalogdb requestdb; do
		kubectl -n $NAMESPACE exec dev-mariadb-galera-mariadb-galera-0 -- mysql -uroot -psecretpassword -e "drop database ${database}"
        done
fi

if [ $COMPONENT == "sdnc" ]; then
        for database in sdnctl; do
		kubectl -n $NAMESPACE exec dev-mariadb-galera-mariadb-galera-0 -- mysql -uroot -psecretpassword -e "drop database ${database}"
        done
fi

for op in secrets configmaps pvc pv deployments statefulsets clusterrolebinding jobs; do
	ARRAY=(`kubectl get $op -n $NAMESPACE | grep $DEPLOYMENT-$COMPONENT | awk '{print $1}'`)
	for i in ${ARRAY[*]}; do
		kubectl delete $op -n $NAMESPACE $i
	done
done

ARRAY=(`kubectl get services -n $NAMESPACE | grep -e ^$COMPONENT | awk '{print $1}'`)
for i in ${ARRAY[*]}; do
	kubectl delete service -n $NAMESPACE $i
done