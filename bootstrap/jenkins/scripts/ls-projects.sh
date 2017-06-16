#!/bin/sh
ssh -p 29418 gerrit.onap.org gerrit ls-projects | grep -v All
