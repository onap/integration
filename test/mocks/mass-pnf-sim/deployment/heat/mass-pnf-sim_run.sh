#!/bin/bash
pushd /root
git clone https://git.onap.org/integration
pushd integration/test/mocks/mass-pnf-sim
./setup.sh
source .tox/MassPnfSim-runtime/bin/activate
