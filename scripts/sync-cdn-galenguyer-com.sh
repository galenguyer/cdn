#!/usr/bin/env bash
HOSTS=`grep -v -P "^\#" hosts`

for HOST in $HOSTS; do
    ssh chef@"$HOST" "sudo bash -c 'mkdir -p /var/www/cdn.galenguyer.com/'"
    rsync -avz --delete -e "ssh" --rsync-path="sudo rsync" /var/www/cdn.galenguyer.com/ chef@"$HOST":/var/www/cdn.galenguyer.com/
    ssh chef@"$HOST" "sudo bash -c 'nginx -t && systemctl reload nginx'"
done
