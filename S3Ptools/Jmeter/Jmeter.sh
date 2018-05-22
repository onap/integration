#!/bin/bash
wget http://redrockdigimark.com/apachemirror//jmeter/binaries/apache-jmeter-4.0.tgz
tar -xf apache-jmeter-4.0.tgz
cd apache-jmeter-4.0/bin/
\rm -rf apache-jmeter-4.0.tgz
./jmeter
