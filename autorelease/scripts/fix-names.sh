#!/bin/bash
##############################################################################
# Copyright (c) 2015, 2016 The Linux Foundation.  All rights reserved.
##############################################################################

# autorelease root dir
ROOT=`git rev-parse --show-toplevel`/autorelease

BUILD_DIR=$ROOT/build

mkdir -p $BUILD_DIR
cd $BUILD_DIR

# MAP of path to a parent pom from the perspective of hosting directory
# starting from the autorelease repo root.
#
# Format:  <groupId>:<artifactId>:<path>

fix_name() {
    pom=$1
    echo -e "\nScanning $pom"
    pomPath=`dirname $pom`

    projectPath=${pomPath#*/}  # Path to pom file from the perspective of hosting repo

    relativePath="$projectPath"  # Calculated relative path to parent pom

    # Update any existing project names
    xmlstarlet ed -P -N x=http://maven.apache.org/POM/4.0.0 \
	       -u "/x:project/x:name" -v "$relativePath" \
	       "$pom" > "${pom}.new"
    mv "${pom}.new" "${pom}"

    # Add missing ones
    xmlstarlet ed -P -N x=http://maven.apache.org/POM/4.0.0 \
               -s "/x:project[count(x:name)=0]" -t elem -n name -v "$relativePath" \
	       "$pom" > "${pom}.new" 
    mv "${pom}.new" "${pom}"
}

# Find all project poms ignoring the /src/ paths (We don't want to scan code)
find . -name pom.xml -not -path "*/src/*" | xargs -I^ -P8 bash -c "$(declare -f fix_name); fix_name ^"
