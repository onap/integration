#!/usr/bin/env bash

# Prerequistes
wget https://releases.rancher.com/cli/v0.6.12/rancher-linux-amd64-v0.6.12.tar.gz
tar xf rancher-linux-amd64-v0.6.12.tar.gz

# Installation
echo '# Privilege elevation needed to move Rancher CLI binary to /usr/local/bin'
sudo mv rancher-v0.6.12/rancher /usr/local/bin/

# Cleanup
rmdir rancher-v0.6.12/
rm rancher-linux-amd64-v0.6.12.tar.gz
