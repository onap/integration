#!/bin/bash

# Setup runtime environment for the Python scripts

virtualenv --version > /dev/null 2>&1 || { echo 'Virtualenv command is not available, exiting'; exit 1; }
pip3 --version > /dev/null 2>&1 || { echo 'python3-pip package is not available, exiting' ; exit 1; }
tox --version > /dev/null 2>&1 || { echo 'tox command is not available, exiting' ; exit 1; }

tox -e MassPnfSim-runtime
echo -e "\n\nNow run:\nsource .tox/MassPnfSim-runtime/bin/activate"
