#!/usr/bin/env bash

#
# @file        test/security/k8s/tools/dublin/get_helm.sh
# @author      Pawel Wieczorek <p.wieczorek2@samsung.com>
# @brief       Utility for obtaining helm tool
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
# # ./get_helm.sh [VERSION [ARCH [SYSTEM]]]
#

# Constants
BINARY='helm'
INSTALL_DIR='/usr/local/bin/'

DEFAULT_VERSION='v2.14.2'
DEFAULT_ARCH='amd64'
DEFAULT_SYSTEM='linux'

# Variables
VERSION="${1:-$DEFAULT_VERSION}"
ARCH="${2:-$DEFAULT_ARCH}"
SYSTEM="${3:-$DEFAULT_SYSTEM}"

URL="https://storage.googleapis.com/kubernetes-helm/${BINARY}-${VERSION}-${SYSTEM}-${ARCH}.tar.gz"
ARCHIVE="${URL##*/}"
DIR="${SYSTEM}-${ARCH}"


# Prerequistes
wget "$URL"
tar xf "$ARCHIVE"

# Installation
mv "${DIR}/${BINARY}" "$INSTALL_DIR"

# Cleanup
rm "$ARCHIVE"
rm -r "$DIR"
