#!/bin/bash

#Stop all simulators 

docker kill dfc_dr-sim
docker kill dfc_dr-redir-sim
docker kill dfc_mr-sim
docker kill dfc_sftp-server
docker kill dfc_ftpes-server-vsftpd

