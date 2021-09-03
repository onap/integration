#!/bin/bash
#
# Modifications copyright (C) 2021 Nokia. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#

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
docker kill dfc_http-https-server0
docker kill dfc_http-https-server1
docker kill dfc_http-https-server2
docker kill dfc_http-https-server3
docker kill dfc_http-https-server4

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
docker rm -f dfc_http-https-server0
docker rm -f dfc_http-https-server1
docker rm -f dfc_http-https-server2
docker rm -f dfc_http-https-server3
docker rm -f dfc_http-https-server4
if [ "$HTTP_TYPE" = "HTTPS" ]
  then
	docker rm -f oom-certservice-post-processor
fi

echo "done"
