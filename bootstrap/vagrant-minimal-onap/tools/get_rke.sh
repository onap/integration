#!/usr/bin/env bash

#
# @file        test/security/k8s/tools/dublin/get_rke.sh
# @author      Pawel Wieczorek <p.wieczorek2@samsung.com>
# @brief       Utility for obtaining RKE tool
#

# Dependencies:
#     wget
#     coreutils
#
# Privileges:
# Script expects to be run with administrative privileges for accessing /usr/local/bin
#
# Usage:
# # ./get_rke.sh [VERSION [ARCH [SYSTEM]]]
#

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
chmod +x "$BINARY"

# Installation
mv "$BINARY" "/usr/local/bin/${BINARY%%_*}" # this also renames binary to "rke"
