#!/usr/bin/env bash

# Script to create files for the FTP server to return upon request.
# The file names matches the files names in the events polled from the MR simulator.
# Intended for execution in the running ftp containers in the ftp-root dir.

NUM=200 #Default number of files 
PNFS=1 #Default number of PNFs
FSIZE="ALL"

if [ $# -eq 1 ]; then 
    NUM=$1
elif [ $# -eq 2 ]; then
    NUM=$1
    PNFS=$2
elif [ $# -eq 3 ]; then
	NUM=$1
    PNFS=$2
    FSIZE=$3
    if [ $3 != "1KB" ] && [ $3 != "1MB" ] && [ $3 != "5MB" ]  && [ $3 != "50MB" ]  && [ $3 != "ALL" ]; then
    	echo "File size shall be 1KB|1MB|5MB|50MB|ALL"
    	exit
    fi
else
    echo "Wrong args, usage: setup-ftp-files-for-image.sh [ <num-files> [ <num-PNFs> [ 1KB|1MB|5MB|50MB ] ] ]"
    exit
fi

echo "Running ftp file creations. " $PNFS " PNFs and " $NUM " files for each PNF with file size(s) "$FSIZE

truncate -s 1KB 1KB.tar.gz
truncate -s 1MB 1MB.tar.gz
truncate -s 5MB 5MB.tar.gz
truncate -s 50MB 50MB.tar.gz

p=0
while [ $p -lt $PNFS ]; do 
    i=0
    while [ $i -lt $NUM ]; do  #Problem with for loop and var substituion in curly bracket....so used good old style loop
    	if [ $FSIZE = "ALL" ] || [ $FSIZE = "1KB" ]; then ln -s 1KB.tar.gz 'A20000626.2315+0200-2330+0200_PNF'$p'-'$i'-1KB.tar.gz' >& /dev/null; fi
        if [ $FSIZE = "ALL" ] || [ $FSIZE = "1MB" ]; then ln -s 1MB.tar.gz 'A20000626.2315+0200-2330+0200_PNF'$p'-'$i'-1MB.tar.gz' >& /dev/null; fi
        if [ $FSIZE = "ALL" ] || [ $FSIZE = "5MB" ]; then ln -s 5MB.tar.gz 'A20000626.2315+0200-2330+0200_PNF'$p'-'$i'-5MB.tar.gz' >& /dev/null; fi
        if [ $FSIZE = "ALL" ] || [ $FSIZE = "50MB" ]; then ln -s 50MB.tar.gz 'A20000626.2315+0200-2330+0200_PNF'$p'-'$i'-50MB.tar.gz' >& /dev/null; fi
    let i=i+1
    done
    let p=p+1
done
