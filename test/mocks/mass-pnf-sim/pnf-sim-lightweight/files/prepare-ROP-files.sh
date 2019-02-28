#!/bin/bash

echo "Creating ROP files"
set -x
mkdir -p onap

dd if=/dev/urandom of=./onap/0.5MB.tar.gz bs=1k count=512
dd if=/dev/urandom of=./onap/1MB.tar.gz bs=1M count=1
dd if=/dev/urandom of=./onap/5MB.tar.gz bs=1M count=5
dd if=/dev/urandom of=./onap/10MB.tar.gz bs=1M count=10