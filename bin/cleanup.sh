#!/bin/bash
docker images --filter "label=de.sandstein.dde=$1"
docker system prune -a -f --filter "label=de.sandstein.dde=$1"