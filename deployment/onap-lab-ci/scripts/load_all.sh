#!/bin/bash -x
./load_influx.sh tlab-heat-daily 1 104
./load_influx.sh tlab-oom-daily 1 110
./load_influx.sh windriver-heat-daily 1 106
./load_influx.sh windriver-oom-daily 1 110
