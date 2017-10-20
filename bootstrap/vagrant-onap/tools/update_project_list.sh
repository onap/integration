#!/bin/bash

ssh $1@gerrit.onap.org -p 29418 gerrit ls-projects > projects.tmp
tail -n +2 projects.tmp > tests/projects.txt
rm projects.tmp
