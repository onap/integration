#!/bin/sh
find $1 -mindepth 0 -type d -exec test -e "{}/pom.xml" ';' -prune -printf "%P\n" | sort
