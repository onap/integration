#!/bin/bash


if [ "$#" -ne 1 ]; then
    echo "$0 <repo>"
    echo "   where <repo> is releases or staging"
    exit 1
fi

set -x
REPO=$1

LOG_DIR=/var/www/html/logs/mirror-nexus/$REPO/
mkdir -p $LOG_DIR

LOG_FILE=$LOG_DIR/$(date +%FT%TZ).log
TAR_FILE=$REPO-$(date +%F).tar

MIRRORS_DIR=/var/www/html/mirrors/nexus.onap.org
REPO_DIR=$MIRRORS_DIR/$REPO
mkdir -p $REPO_DIR
cd $REPO_DIR

wget -nv --mirror --random-wait --no-if-modified-since --no-parent -e robots=off --reject "index.html*" -nH --cut-dirs=3 "https://nexus.onap.org/content/repositories/$REPO/" -o /dev/stdout | sed -u "s|URL:https://nexus.onap.org/content/repositories/$REPO/||g" | sed -u 's| ->.*||g' > $LOG_FILE

cd $MIRRORS_DIR
tar cvf $TAR_FILE.part $REPO/
mv -b $TAR_FILE.part $TAR_FILE
