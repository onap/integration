#!/bin/bash

IFS='
'

if [ -z $1 ]; then
  echo "ONAP component name missing"
  echo "Usage: ./cleanup.sh ONAP_COMPONENT_NAME"
  exit 1
fi

COMPONENT=$1

if [ $COMPONENT == "dcae" ] || [ $COMPONENT == "DCAE" ]; then
  kubectl delete service consul -n onap
fi

for op in secrets configmaps pv services deployments statefulsets; do
  ARRAY=(`kubectl get $op -n onap | grep $COMPONENT | awk '{print $1}'`)
  for i in ${ARRAY[*]}; do
    kubectl delete $op -n onap $i
  done
done
