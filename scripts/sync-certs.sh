#!/usr/bin/env bash
# copy certs from bastion to local to host

# exit if a command fails
set -o errexit
set -o pipefail
# exit if required variables aren't set
set -o nounset

if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root"
  exit
fi

bastion="10.1.1.111"
HOSTS="$(grep -v -P '^\#' hosts)"

eval "$(ssh-agent)"
ssh-add ~/.ssh/id_rsa

# copy from bastion to tmp
rsync -avz --delete -e "ssh" --rsync-path="sudo rsync" chef@"$bastion":/root/.acme.sh/katy.pw/ /etc/ssl/katy.pw/
rsync -avz --delete -e "ssh" --rsync-path="sudo rsync" chef@"$bastion":/root/.acme.sh/katy.su/ /etc/ssl/katy.su/
rsync -avz --delete -e "ssh" --rsync-path="sudo rsync" chef@"$bastion":/root/.acme.sh/antifausa.net/ /etc/ssl/antifausa.net/
rsync -avz --delete -e "ssh" --rsync-path="sudo rsync" chef@"$bastion":/root/.acme.sh/galenguyer.com/ /etc/ssl/galenguyer.com/

for HOST in $HOSTS; do
# copy from tmp to host
    ssh chef@"$HOST" sudo mkdir -p /etc/ssl/{katy.{pw,su},antifausa.net,galenguyer.com}
    rsync -avz -e "ssh" --rsync-path="sudo rsync" /etc/ssl/katy.pw/ chef@"$HOST":/etc/ssl/katy.pw/
    rsync -avz -e "ssh" --rsync-path="sudo rsync" /etc/ssl/katy.su/ chef@"$HOST":/etc/ssl/katy.su/
    rsync -avz -e "ssh" --rsync-path="sudo rsync" /etc/ssl/antifausa.net/ chef@"$HOST":/etc/ssl/antifausa.net/
    rsync -avz -e "ssh" --rsync-path="sudo rsync" /etc/ssl/galenguyer.com/ chef@"$HOST":/etc/ssl/galenguyer.com/
    rsync -avz -e "ssh" --rsync-path="sudo rsync" /home/chef/.ca/certificates/default/ chef@"$HOST":/etc/ssl/default/
done
