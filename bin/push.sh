#!/bin/bash

docker login
docker push "sandstein/$1" -a