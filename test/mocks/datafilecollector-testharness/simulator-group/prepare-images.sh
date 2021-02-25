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

#Script for manually preparing images for mr-sim, dr-sim, dr-redir-sim and sftp server.

#Build MR sim
cd ../mr-sim

docker build -t mrsim:latest .

#Build DR sim common image
cd ../dr-sim

docker build -t drsim_common:latest .

#Build image for ftpes server
cd ../ftpes-sftp-server

docker build -t ftpes_vsftpd:latest -f Dockerfile-ftpes .
