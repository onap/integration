#!/bin/bash

log_path=$(pwd)/logs
docker run -d -v $log_path:/generic_sim_logs -p 8081:8081 --name generic_sim generic_sim
