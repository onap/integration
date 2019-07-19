#!/usr/bin/env bash

# Constants
DEFAULT_VERSION='v0.2.1'
DEFAULT_ARCH='amd64'
DEFAULT_SYSTEM='linux'

# Variables
VERSION="${1:-$DEFAULT_VERSION}"
ARCH="${2:-$DEFAULT_ARCH}"
SYSTEM="${3:-$DEFAULT_SYSTEM}"

BINARY="rke_${SYSTEM}-${ARCH}"
URL="https://github.com/rancher/rke/releases/download/${VERSION}/${BINARY}"


# Prerequistes
wget "$URL"
chmod +x "${BINARY}"

# Installation
echo '# Privilege elevation needed to move RKE binary to /usr/local/bin'
sudo mv "${BINARY}" "/usr/local/bin/${BINARY%%_*}" # this also renames binary to "rke"
