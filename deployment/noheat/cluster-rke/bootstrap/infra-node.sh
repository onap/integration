#!/bin/sh

# Prerequisites
sudo apt-get install --yes git python3-pip

# Dependencies
git clone https://git.onap.org/oom/offline-installer
pip3 install -r offline-installer/build/download/requirements.txt

# Main
DOWNLOADS="${HOME}/onap/downloads"

mkdir -p "$DOWNLOADS"

cd offline-installer
build/download/download.py --http build/data_lists/infra_bin_utils.list "$DOWNLOADS"

ln -s "${DOWNLOADS}/github.com/rancher/rke/releases/download/v1.2.4/rke_linux-amd64" "${DOWNLOADS}/rke_linux-amd64" # flattening expected by installation-server
