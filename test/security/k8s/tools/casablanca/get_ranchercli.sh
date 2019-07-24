#!/usr/bin/env bash

#
# @file        test/security/k8s/tools/casablanca/get_ranchercli.sh
# @author      Pawel Wieczorek <p.wieczorek2@samsung.com>
# @brief       Utility for obtaining Rancher CLI tool
#

# Dependencies:
#     wget
#     tar
#     coreutils
#
# Privileges:
# Script expects to be run with administrative privileges for accessing /usr/local/bin
#
# Usage:
# # ./get_ranchercli.sh [VERSION [ARCH [SYSTEM]]]
#

# Constants
DEFAULT_VERSION='v0.6.12'
DEFAULT_ARCH='amd64'
DEFAULT_SYSTEM='linux'

# Variables
VERSION="${1:-$DEFAULT_VERSION}"
ARCH="${2:-$DEFAULT_ARCH}"
SYSTEM="${3:-$DEFAULT_SYSTEM}"

ARCHIVE="rancher-${SYSTEM}-${ARCH}-${VERSION}.tar.gz"
DIRECTORY="rancher-${VERSION}"
URL="https://releases.rancher.com/cli/${VERSION}/${ARCHIVE}"


# Prerequistes
wget "$URL"
tar xf "$ARCHIVE"

# Installation
mv "${DIRECTORY}/rancher" /usr/local/bin/

# Cleanup
rmdir "$DIRECTORY"
rm "$ARCHIVE"
