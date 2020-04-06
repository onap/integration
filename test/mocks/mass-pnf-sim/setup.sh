#!/bin/bash

virtualenv --version > /dev/null || { echo 'Virtualenv command is not available, exiting' ; sleep 10; exit 1; }
pip3 --version > /dev/null || { echo 'python3-pip package is not available, exiting' ; sleep 10; exit 1; }


if [ -d ".env" ]; then
	echo ".env is prepared"
else
	virtualenv -p python3 .env
fi

source .env/bin/activate && pip3 install -r requirements.txt
