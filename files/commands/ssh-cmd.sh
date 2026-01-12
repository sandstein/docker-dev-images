#!/bin/sh
set -e

while IFS= read -r line; do
  echo "building tunnel for: $line"
  AUTOSSH_GATETIME=0 autossh -M 0 -Nf $line < /dev/null
done < /home/ssh/.tunnel/tunnel.conf

while true; do
    sleep 4096
done
