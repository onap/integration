#/bin/bash

#Script for manually preparing images for mr-sim, dr-sim, dr-redir-sim and sftp server.

#Build MR sim
cd ../mr-sim

docker build -t mrsim:latest .

#Build DR sim common image
cd ../dr-sim

docker build -t drsim_common:latest .

#Build image for ftps server
cd ../ftps-sftp-server

docker build -t ftps_vsftpd:latest -f Dockerfile-ftps .

