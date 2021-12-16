#!/usr/bin/env bash

[ -z "$1" ] && echo "No host supplied" && exit 1

for host in "$@"; do
  echo "Syncing to $host..."
  rsync -rah --info=progress2 --delete ./ $host:~/nixos/
done
