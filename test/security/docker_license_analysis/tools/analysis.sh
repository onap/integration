#/bin/sh
cd ~/ternenv
source bin/activate
tern report -f json -o report.json -i $IMAGE
tern report -f json -o report-scancode.json -x scancode -i $IMAGE
