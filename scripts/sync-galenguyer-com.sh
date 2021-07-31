#!/usr/bin/env bash
HOSTS=`grep -v -P "^\#" hosts`

for HOST in $HOSTS; do
    ssh chef@"$HOST" "sudo bash -c 'mkdir -p /var/www/galenguyer.com/'"
    rsync -avz --delete -e "ssh" --rsync-path="sudo rsync" /var/www/galenguyer.com/ chef@"$HOST":/var/www/galenguyer.com/
    ssh chef@"$HOST" "sudo bash -c 'nginx -t && systemctl reload nginx'"
    ssh chef@"$HOST" "sudo bash -c 'chown www-data:www-data /var/www/galenguyer.com -Rc | grep -iv retained'"
done
