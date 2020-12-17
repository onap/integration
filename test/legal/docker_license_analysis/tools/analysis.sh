#!/bin/env sh
# Analysis is run twice to populate tern cache:
# https://github.com/tern-tools/tern/issues/818

TERNVENV="${TERNVENV:-$HOME/ternvenv}"

if [ -d "$TERNVENV" ]; then
  cd $TERNVENV
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

if [ -n "$IMAGE" ]; then
  echo 'Running Docker Image analysis'
  tern report -f json -o /dev/null -i "$IMAGE"
  tern report -f json -o report-scancode.json -x scancode -i "$IMAGE"
elif [ -f "$FILE" ]; then
  echo 'Running Dockerfile analysis'
  tern report -f json -o /dev/null -d $FILE
  tern report -f json -o report-scancode.json -x scancode -d $FILE
else
  echo "\$IMAGE is not set and \$FILE does not point to a file." >&2;
fi

