#!/bin/bash
#grafana install for the use of locust
# localgosh:80(grafana) & localhost:81
pip install docker==3.1.4
git clone https://github.com/kamon-io/docker-grafana-graphite.git
cd docker-grafana-graphite
make up

