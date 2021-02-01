#/bin/bash

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

#Build image for http server
cd ../http-https-server

docker build -t http_https_httpd:latest -f Dockerfile-http-https .
