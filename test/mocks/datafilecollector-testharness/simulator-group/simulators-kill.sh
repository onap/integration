#!/bin/bash

#Script to kill and remove all simulators
docker logs dfc_mr-sim
echo "Killing simulator containers"
docker kill dfc_dr-sim
docker kill dfc_dr-redir-sim
docker kill dfc_mr-sim
docker kill dfc_sftp-server0
docker kill dfc_sftp-server1
docker kill dfc_sftp-server2
docker kill dfc_sftp-server3
docker kill dfc_sftp-server4
docker kill dfc_ftpes-server-vsftpd0
docker kill dfc_ftpes-server-vsftpd1
docker kill dfc_ftpes-server-vsftpd2
docker kill dfc_ftpes-server-vsftpd3
docker kill dfc_ftpes-server-vsftpd4
docker kill dfc_cbs
docker kill dfc_consul

echo "Removing simulator containers"
docker rm dfc_dr-sim
docker rm dfc_dr-redir-sim
docker rm dfc_mr-sim
docker rm dfc_sftp-server0
docker rm dfc_sftp-server1
docker rm dfc_sftp-server2
docker rm dfc_sftp-server3
docker rm dfc_sftp-server4
docker rm dfc_ftpes-server-vsftpd0
docker rm dfc_ftpes-server-vsftpd1
docker rm dfc_ftpes-server-vsftpd2
docker rm dfc_ftpes-server-vsftpd3
docker rm dfc_ftpes-server-vsftpd4
docker rm dfc_cbs
docker rm dfc_consul

echo "done"