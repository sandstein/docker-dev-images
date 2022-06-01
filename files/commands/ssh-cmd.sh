#!/bin/sh
set -e

while IFS= read -r line; do
  echo "building tunnel for: $line"
  ssh -Nf $line < /dev/null
done < /home/ssh/.tunnel/tunnel.conf

while true; do
    sleep 4096
done
