#!/bin/bash
# Copyright 2019 AT&T Intellectual Property. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

KUBE_VERSION=$1
LOCATION=$2

COMMANDS="kubectl helm make java az"

CLI_MAJOR="2"
CLI_MINOR="0"
CLI_INC="75"

function check_requirement() {
  req=$1

  command -v $1
  if [ $? -ne 0 ]; then
    echo "$1 was not found on machine. Please install it before proceeding."
    exit 1
  fi
}

echo "Checking requirements are installed..."

for req in $COMMANDS; do
  check_requirement $req
done

echo "Checking K8 version is available in Azure..."
if [ -z "$KUBE_VERSION" ]; then
  echo "K8 version not provided in cloud.conf."
  echo "Update cloud.conf with the desired version."
  exit 1
fi

if [ -z "$LOCATION" ]; then
  echo "Location not provided in cloud.conf."
  echo "Update cloud.conf with the desired location."
  exit 1
fi

supported_k8_versions=`az aks get-versions --location $LOCATION --output json --query 'orchestrators[].orchestratorVersion'`
echo $supported_k8_versions | grep -q $KUBE_VERSION
if [ $? -ne 0 ]; then
  echo "K8 version $KUBE_VERSION is not supported in location $LOCATION"
  echo "The supported versions are $supported_k8_versions."
  echo "Update cloud.conf with a supported version."
  exit 1
fi

echo "Checking Azure CLI version..."
installed_cli_version=`az --version | grep -e "^azure-cli"  | awk '{print $2}'`
installed_major=`echo $installed_cli_version | cut -d "." -f 1`
installed_minor=`echo $installed_cli_version | cut -d "." -f 2`
installed_inc=`echo $installed_cli_version | cut -d "." -f 3`

if [ $installed_major -lt $CLI_MAJOR ]; then
  echo "Azure cli version is out of date."
  echo "Major version required is $CLI_MAJOR but $installed_major is installed."
  exit 1
fi

if [ $installed_minor -lt $CLI_MINOR ]; then
  echo "Azure cli version is out of date."
  echo "Minor version required is $CLI_INC but $installed_inc is installed."
  exit 1
fi

if [ $installed_inc -lt $CLI_INC ]; then
  echo "Azure cli version is out of date."
  echo "Incremental version required is $CLI_INC but $installed_inc is installed."
  exit 1
fi

echo "Checking kubectl version is compatible with the K8 version..."
kubectl_version=`kubectl version --client --short | awk '{print $3}'`
kubectl_major=`echo $kubectl_version | cut -d "." -f 1 | sed 's/v//'`
kubectl_minor=`echo $kubectl_version | cut -d "." -f 2`
k8_major=`echo $KUBE_VERSION | cut -d "." -f 1`
k8_minor=`echo $KUBE_VERSION | cut -d "." -f 2`

if [ $kubectl_major -ne $k8_major ]; then
  echo "kubectl major version $kubectl_major doesn't equal kubernetes server version $k8_major"
  exit 1
fi

minor_difference=`echo "$(($kubectl_minor-$k8_minor))"`
minor_abs_diff=`echo $minor_difference | tr -d -`
if [ $minor_abs_diff -gt 1 ]; then
  echo "The difference between k8 minor version $KUBE_VERSION and kubectl minor version $kubectl_version is greater than 1"
  echo "Kubernetes supports kubectl within 1 minor version."
  exit 1
fi

echo "All requirements satisfied..."
sleep 1
