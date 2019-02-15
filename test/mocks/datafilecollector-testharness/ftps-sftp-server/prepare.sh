#!/bin/bash

mkdir -p files/onap

dd if=/dev/urandom of=./files/onap/0.5MB.tar.gz bs=1k count=512
dd if=/dev/urandom of=./files/onap/1MB.tar.gz bs=1M count=1
dd if=/dev/urandom of=./files/onap/5MB.tar.gz bs=1M count=5
dd if=/dev/urandom of=./files/onap/10MB.tar.gz bs=1M count=10

sudo chown root:root ./configuration/vsftpd_ssl.conf
