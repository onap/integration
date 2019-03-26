#!/bin/bash

# Script to create files for the FTP server to return upon request.
# The file names matches the files names in the events polled from the MR simulator.
# Intended for execution in the running ftp containers in the ftp-root dir.

echo "Running ftp file creations"

NUM=200 #Default number of files 

if [ $# -eq 1 ]; then 
    NUM=$1
fi

truncate -s 1MB 1MB.tar.gz
truncate -s 5MB 5MB.tar.gz
truncate -s 50MB 50MB.tar.gz


i=0
while [ $i -lt $NUM ]; do  #Problem with for loop and var substituion in curly bracket....so used good old style loop
   ln -s 1MB.tar.gz 1MB_$i.tar.gz
   ln -s 5MB.tar.gz 5MB_$i.tar.gz
   let i=i+1
done


ln -s 50MB.tar.gz 50MB_0.tar.gz   #Large file, only for single file test
