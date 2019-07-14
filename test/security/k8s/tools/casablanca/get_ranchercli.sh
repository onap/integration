#!/usr/bin/env bash

# Constants
DEFAULT_VERSION='v0.6.12'
DEFAULT_ARCH='amd64'
DEFAULT_SYSTEM='linux'

# Variables
VERSION="${1:-$DEFAULT_VERSION}"
ARCH="${2:-$DEFAULT_ARCH}"
SYSTEM="${3:-$DEFAULT_SYSTEM}"

ARCHIVE="rancher-${SYSTEM}-${ARCHITECTURE}-${VERSION}.tar.gz"
DIRECTORY="rancher-${VERSION}"
URL="https://releases.rancher.com/cli/${VERSION}/${ARCHIVE}"


# Prerequistes
wget "$URL"
tar xf "$ARCHIVE"

# Installation
echo '# Privilege elevation needed to move Rancher CLI binary to /usr/local/bin'
sudo mv "${DIRECTORY}/rancher" /usr/local/bin/

# Cleanup
rmdir "$DIRECTORY"
rm "$ARCHIVE"
