#/bin/bash

#Script for manually starting all simulators with test setting below

export DR_TC="--tc normal"
export DR_REDIR_TC="--tc normal"
export MR_TC="--tc100"
export BC_TC=""  #Not in use yet
export NUM_FTPFILES="10"
export NUM_PNFS="700"
export FILE_SIZE="1MB"
export FTP_TYPE="SFTP"

source ./simulators-start.sh