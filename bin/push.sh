#!/bin/bash

docker login
docker push --all-tags "sandstein/$1"