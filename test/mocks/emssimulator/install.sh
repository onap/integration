#!/bin/bash

readonly old_pwd=$PWD
cd swm/sw_server_simulator

for i in `ls -1`; do
    if [ -d $i ]; then
        cd $i
        echo $i
        zip -r ${i}.zip *
        mv ${i}.zip ..
        cd $OLDPWD
    fi
done

cd $old_pwd

