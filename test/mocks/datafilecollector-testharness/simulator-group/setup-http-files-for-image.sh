#!/usr/bin/env bash

# Script to create files for the HTTP server to return upon request.
# The file names matches the files names in the events polled from the MR simulator.
# Intended for execution in the running http containers in the http-root dir.

NUM=200 #Default number of files
PNFS=1 #Default number of PNFs
FSIZE="ALL"
PREFIXES="A"
HTTP_SERV_INDEX=0
NUM_HTTP_SERVERS=1

if [ $# -ge 1 ]; then
    NUM=$1
fi
if [ $# -ge 2 ]; then
    PNFS=$2
fi
if [ $# -ge 3 ]; then
    FSIZE=$3
    if [ $3 != "1KB" ] && [ $3 != "1MB" ] && [ $3 != "5MB" ]  && [ $3 != "50MB" ]  && [ $3 != "ALL" ]; then
    	echo "File size shall be 1KB|1MB|5MB|50MB|ALL"
    	exit
    fi
fi
if [ $# -ge 4 ]; then
	PREFIXES=$4
fi
if [ $# -ge 5 ]; then
	NUM_HTTP_SERVERS=$5
fi
if [ $# -ge 6 ]; then
	HTTP_SERV_INDEX=$6
fi
if [ $# -lt 1 ] || [ $# -gt 6 ]; then
    echo "Wrong args, usage: setup-http-files-for-image.sh [ <num-files> [ <num-PNFs> [ 1KB|1MB|5MB|50MB [ <comma-separated-file-name-prefixs> [ <number-of-http-servers> <http-server-index> ] ] ] ] ] ]"
    exit
fi

echo "Running http file creations. " $PNFS " PNFs and " $NUM " files for each PNF with file size(s) " $FSIZE "and file prefixe(s) " $PREFIXES " in http servers with index " $HTTP_SERV_INDEX

truncate -s 1KB 1KB.tar.gz
truncate -s 1MB 1MB.tar.gz
truncate -s 5MB 5MB.tar.gz
truncate -s 50MB 50MB.tar.gz

for fnp in ${PREFIXES//,/ }
do
	p=0
	while [ $p -lt $PNFS ]; do
		if [[ $(($p%$NUM_HTTP_SERVERS)) == $HTTP_SERV_INDEX ]]; then
    		i=0
    		while [ $i -lt $NUM ]; do  #Problem with for loop and var substituion in curly bracket....so used good old style loop
    			if [ $FSIZE = "ALL" ] || [ $FSIZE = "1KB" ]; then ln -s 1KB.tar.gz $fnp'20000626.2315+0200-2330+0200_PNF'$p'-'$i'-1KB.tar.gz' >& /dev/null; fi
        		if [ $FSIZE = "ALL" ] || [ $FSIZE = "1MB" ]; then ln -s 1MB.tar.gz $fnp'20000626.2315+0200-2330+0200_PNF'$p'-'$i'-1MB.tar.gz' >& /dev/null; fi
        		if [ $FSIZE = "ALL" ] || [ $FSIZE = "5MB" ]; then ln -s 5MB.tar.gz $fnp'20000626.2315+0200-2330+0200_PNF'$p'-'$i'-5MB.tar.gz' >& /dev/null; fi
        		if [ $FSIZE = "ALL" ] || [ $FSIZE = "50MB" ]; then ln -s 50MB.tar.gz $fnp'20000626.2315+0200-2330+0200_PNF'$p'-'$i'-50MB.tar.gz' >& /dev/null; fi
    			let i=i+1
    		done
    	fi
    	let p=p+1
	done
done
