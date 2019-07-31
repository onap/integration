#!/usr/bin/env bash

#
# @file        test/security/k8s/tools/dublin/setup_kubectl.sh
# @author      Pawel Wieczorek <p.wieczorek2@samsung.com>
# @brief       Utility for setting up kubectl tool for Dublin cluster
#

# Dependencies:
#     coreutils
#
# Privileges:
# Script expects to be run with administrative privileges for accessing /usr/local/bin
#
# Usage:
# # ./setup_kubectl.sh [RKE_CONFIG [KUBE_DIR [KUBE_CONFIG [KUBE_CONTEXT]]]]
#

# Constants
BASHRC='.bashrc'
BASH_ALIASES='.bash_aliases'
USE_ONAP_ALIAS='useonap'

DEFAULT_RKE_CONFIG='kube_config_cluster.yml'
DEFAULT_KUBE_DIR='.kube'
DEFAULT_KUBE_CONFIG='config.onap'
DEFAULT_KUBE_CONTEXT='onap'

# Variables
RKE_CONFIG="${1:-$DEFAULT_RKE_CONFIG}"
KUBE_DIR="${2:-${HOME}/${DEFAULT_KUBE_DIR}}"
KUBE_CONFIG="${3:-$DEFAULT_KUBE_CONFIG}"
KUBE_CONTEXT="${4:-$DEFAULT_KUBE_CONTEXT}"

USE_ONAP="f() { export KUBECONFIG=${KUBE_DIR}/${KUBE_CONFIG}; kubectl config use-context ${KUBE_CONTEXT}; }; f"
USE_ONAP_CONFIG="$(cat<<CONFIG

# Use ONAP context for kubectl utility (defined in ${HOME}/${BASH_ALIASES})
${USE_ONAP_ALIAS}
CONFIG
)"


# Prerequistes
mkdir -p "$KUBE_DIR"
echo "alias ${USE_ONAP_ALIAS}='${USE_ONAP}'" >> "${HOME}/${BASH_ALIASES}"

# Setup
cp "$RKE_CONFIG" "${KUBE_DIR}/${KUBE_CONFIG}"

# Post-setup
echo "$USE_ONAP_CONFIG" >> "${HOME}/${BASHRC}"
