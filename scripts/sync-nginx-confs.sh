#!/usr/bin/env bash
HOSTS=`grep -v -P "^\#" hosts`

for HOST in $HOSTS; do
    rsync -avz --delete -e "ssh" --rsync-path="sudo rsync" ./nginx/ chef@"$HOST":/etc/nginx/
    ssh chef@"$HOST" "sudo bash -c 'nginx -t && systemctl reload nginx'"
done
