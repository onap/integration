#/bin/bash
#
# Modifications copyright (C) 2021 Nokia. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

# Script for manually starting all simulators with test setting below

export MR_TC="--tc710"                                 # Test behaviour for MR sim
export MR_GROUPS="OpenDcae-c12:PM_MEAS_FILES"          # Comma-separated list of <consumer-group>:<change-identifier>
export MR_FILE_PREFIX_MAPPING="PM_MEAS_FILES:A"        # Comma-separated list of <change-identifer>:<file-name-prefix>

export DR_TC="--tc normal"                             # Test behaviour for DR sim
export DR_FEEDS="1:A,2:B,3:C,4:D"                      # Comma-separated of <feed-id>:<file-name-prefixes> for DR sim

export DR_REDIR_TC="--tc normal"                       # Test behaviour for DR redir sim
export DR_REDIR_FEEDS="1:A,2:B,3:C,4:D"                # Comma-separated of <feed-id>:<file-name-prefixes> for DR redir sim

export NUM_PNFS="700"                                  # Number of unuqie PNFs to generate file for
export FILE_SIZE="1MB"                                 # File size for file (1KB, 1MB, 5MB, 50MB or ALL)

export NUM_FTPFILES="105"                              # Number of FTP files to generate per PNF
export FTP_TYPE="SFTP"                                 # Type of FTP files to generate (SFTP, FTPES or ALL)
export FTP_FILE_PREFIXES="A,B,C,D"                     # Comma separated list of file name prefixes for ftp files
export NUM_FTP_SERVERS=1                               # Number of FTP server to distribute the PNFs (Max 5)

export NUM_HTTPFILES="105"                              # Number of HTTP files to generate per PNF
export HTTP_TYPE="HTTP"                                 # Type of HTTP files to generate (HTTP, HTTPS or ALL)
export HTTP_FILE_PREFIXES="A,B,C,D"                     # Comma separated list of file name prefixes for http files
export NUM_HTTP_SERVERS=1                               # Number of HTTP server to distribute the PNFs (Max 5)
export BASIC_AUTH_LOGIN=demo
export BASIC_AUTH_PASSWORD=demo123456!

export SFTP_SIMS="localhost:21,localhost:22,localhost:23,localhost:24,localhost:25"  # Comma separated list for SFTP servers host:port
export FTPES_SIMS="localhost:1022,localhost:1023,localhost:1024,localhost:1026,localhost:1026" # Comma separated list for FTPES servers host:port
export HTTP_SIMS="localhost:81,localhost:82,localhost:83,localhost:84,localhost:85"  # Comma separated list for HTTP servers host:port
export HTTP_JWT_SIMS="localhost:32001,localhost:32002,localhost:32003,localhost:32004,localhost:32005"  # Comma separated list for HTTP JWT servers host:port
export HTTPS_SIMS="localhost:444,localhost:445,localhost:446,localhost:447,localhost:448"  # Comma separated list for HTTPS (enabling client certificate authorization and basic authorization) servers host:port
export HTTPS_SIMS_NO_AUTH="localhost:8081,localhost:8082,localhost:8083,localhost:8084,localhost:8085"  # Comma separated list for HTTPS (with no authorization) servers host:port
export HTTPS_JWT_SIMS="localhost:32101,localhost:32102,localhost:32103,localhost:32104,localhost:32105"  # Comma separated list for HTTPS JWT servers host:port

export DR_REDIR_SIM="localhost"                               # Hostname of DR redirect server

source ./simulators-start.sh
