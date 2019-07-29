#!/usr/bin/env bash

#
# @file        test/security/k8s/tools/dublin/get_kubectl.sh
# @author      Pawel Wieczorek <p.wieczorek2@samsung.com>
# @brief       Utility for obtaining kubectl tool
#

# Dependencies:
#     wget
#     coreutils
#
# Privileges:
# Script expects to be run with administrative privileges for accessing /usr/local/bin
#
# Usage:
# # ./get_kubectl.sh [VERSION [ARCH [SYSTEM]]]
#

# Constants
BINARY='kubectl'
INSTALL_DIR='/usr/local/bin/'

DEFAULT_VERSION='v1.13.5'
DEFAULT_ARCH='amd64'
DEFAULT_SYSTEM='linux'

# Variables
VERSION="${1:-$DEFAULT_VERSION}"
ARCH="${2:-$DEFAULT_ARCH}"
SYSTEM="${3:-$DEFAULT_SYSTEM}"

URL="https://storage.googleapis.com/kubernetes-release/release/${VERSION}/bin/${SYSTEM}/${ARCH}/${BINARY}"


# Prerequistes
wget "$URL"
chmod +x "$BINARY"

# Installation
mv "$BINARY" "$INSTALL_DIR"
