#!/bin/env sh
# Analysis is run twice to populate tern cache:
# https://github.com/tern-tools/tern/issues/818

TERNVENV="${TERNVENV:-$HOME/ternvenv}"

if [ -d "$TERNVENV" ]; then
  cd ternvenv
  if [ -f bin/activate ]; then
    . bin/activate
  else
    echo "Tern virtual environment is not initialized!" >&2;
    exit 1
  fi
else
  echo "Ternenv directory not found, if it is not in $HOME/ternvenv set the \$TERNVENV to your location." >&2;
  exit 1
fi

if [ -z "$IMAGE" ]; then
  echo 'Running Dockerfile analysis'
  tern report -f json -o /dev/null -d "$IMAGE"   tern report -f json -o report-scancode.json -x scancode -d $HOME/ternvenv/Dockerfile
  tern report -f json -o report-scancode.json -x scancode -d $HOME/ternvenv/Dockerfile
else
  echo 'Running Docker Image analysis'
  tern report -f json -o /dev/null -i "$IMAGE"
  tern report -f json -o report-scancode.json -x scancode -i "$IMAGE"
fi

