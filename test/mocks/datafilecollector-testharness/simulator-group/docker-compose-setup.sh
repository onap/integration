#/bin/bash

# Script for manually starting all simulators with test setting below
# Matching json config is needed in CBS/Consul as well. Use consul_config.sh to add config to consul

export MR_TC="--tc710"                                 # Test behaviour for MR sim
export MR_GROUPS="OpenDcae-c12:PM_MEAS_FILES"          # Comma-separated list of <consumer-group>:<change-identifier>
export MR_FILE_PREFIX_MAPPING="PM_MEAS_FILES:A"        # Comma-separated list of <change-identifer>:<file-name-prefix>

export DR_TC="--tc normal"                             # Test behaviour for DR sim
export DR_FEEDS="1:A,2:B,3:C,4:D"                      # Comma-separated of <feed-id>:<file-name-prefixes> for DR sim

export DR_REDIR_TC="--tc normal"                       # Test behaviour for DR redir sim
export DR_REDIR_FEEDS="1:A,2:B,3:C,4:D"                # Comma-separated of <feed-id>:<file-name-prefixes> for DR redir sim

export NUM_FTPFILES="105"                              # Number of FTP files to generate per PNF
export NUM_PNFS="700"                                  # Number of unuqie PNFs to generate FTP file for
export FILE_SIZE="1MB"                                 # File size for FTP file (1KB, 1MB, 5MB, 50MB or ALL)
export FTP_TYPE="SFTP"                                 # Type of FTP files to generate (SFTP, FTPES or ALL)
export FTP_FILE_PREFIXES="A,B,C,D"                     # Comma separated list of file name prefixes for ftp files
export NUM_FTP_SERVERS=1                               # Number of FTP server to distribute the PNFs (Max 5)

export SFTP_SIMS="localhost:21,localhost:22,localhost:23,localhost:24,localhost:25"  # Comma separated list for SFTP servers host:port
export FTPES_SIMS="localhost:1022,localhost:1023,localhost:1024,localhost:1026,localhost:1026" # Comma separated list for FTPES servers host:port

export DR_REDIR_SIM="localhost"                               # Hostname of DR redirect server

source ./simulators-start.sh
