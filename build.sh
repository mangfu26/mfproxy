#!/bin/bash

version=$(cat ./version.txt)
image_name="mfproxy:v$version"
docker rmi $image_name
docker build -t $image_name --no-cache .