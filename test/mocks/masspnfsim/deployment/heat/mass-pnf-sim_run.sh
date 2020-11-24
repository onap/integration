#!/bin/bash
pushd /root
git clone https://git.onap.org/integration
pushd integration/test/mocks/masspnfsim
./setup.sh
source .tox/MassPnfSim-runtime/bin/activate
./mass-pnf-sim.py build
./mass-pnf-sim.py bootstrap --count $SIMULATOR_INSTANCES --urlves $VES_URL --ipfileserver $FILE_SERVER --typefileserver ftps --ipstart 10.11.0.16 --user $FTP_USER --password $FTP_PASSWORD
./mass-pnf-sim.py start
sleep 30
./mass-pnf-sim.py trigger
