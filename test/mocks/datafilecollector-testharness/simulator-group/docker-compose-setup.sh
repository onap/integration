#/bin/bash

#Script for manually starting all simulators with test setting below

export DR_TC="--tc normal"           #Test behaviour for DR sim
export DR_REDIR_TC="--tc normal"     #Test behaviour for DR redir sim
export MR_TC="--tc710"               #Test behaviour for MR sim
export BC_TC=""  #Not in use yet
export NUM_FTPFILES="105"            #Number of FTP files to generate per PNF
export NUM_PNFS="700"                #Number of unuqie PNFs to generate FTP file for
export FILE_SIZE="1MB"               #File size for FTP file (1KB, 1MB, 5MB, 50MB or ALL)
export FTP_TYPE="SFTP"               #Type of FTP files to generate (SFTP, FTPS or ALL)

source ./simulators-start.sh