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

fix_relative_paths() {
    PARENT_MAP=(
        "org.openo.oparent:oparent:oparent"
        "org.openo.nfvo:nfvo-root:nfvo"
    )

    pom=$1
    echo "Scanning $pom"
    pomPath=`dirname $pom`

    # Find and replace parent poms
    for parent in "${PARENT_MAP[@]}"; do
        map=${parent#*:}       #

        groupId=${parent%%:*}  # Maven groupId
        artifactId=${map%%:*}  # Maven artifactId
        projectPath=${map#*:}  # Path to pom file from the perspective of hosting repo

	# Compute relative path to parent pom
	relativePath=`python -c "import os.path; print os.path.relpath('$projectPath','$pomPath')"`

        # Standardize POM XML formatting
        xmlstarlet fo "$pom" > "${pom}.old"

        # Update any existing relativePath values
        xmlstarlet ed -P -N x=http://maven.apache.org/POM/4.0.0 \
            -u "//x:parent[x:artifactId=\"$artifactId\" and x:groupId=\"$groupId\"]/x:relativePath" \
            -v "$relativePath" "${pom}" > "${pom}.new1"

        # Add missing ones
        xmlstarlet ed -P -N x=http://maven.apache.org/POM/4.0.0 \
            -s "//x:parent[x:artifactId=\"$artifactId\" and x:groupId=\"$groupId\" and count(x:relativePath)=0]" \
            -t elem -n relativePath -v "$relativePath" "${pom}.new1" > "${pom}.new2"

        # Standardize POM XML formatting again
        xmlstarlet fo "${pom}.new2" > "${pom}.new"

        diff -u "${pom}.old" "${pom}.new"
        cp "${pom}.new" "${pom}"
    done
}

# Find all project poms ignoring the /src/ paths (We don't want to scan code)
find . -name pom.xml -not -path "*/src/*" | sort | xargs -I^ bash -c "$(declare -f fix_relative_paths); fix_relative_paths ^"
