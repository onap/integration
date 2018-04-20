#!/bin/bash
set -x

rm -rf logs/*

docker stop generic_sim
docker rm generic_sim
docker rmi generic_sim