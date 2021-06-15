#!/bin/bash
#
# Build system iso image

set -e

script_path=$(readlink -f `dirname $0`)

# Generate file system has Docker image

docker build -t retrogaming-filesystem $script_path/../

# Extract Docker image filesystem

container_id=$(docker run -d retrogaming-filesystem /bin/true)
docker export -o $script_path/../tmp/filesystem.tar $container_id

# Generate bootable iso image with filesystem data

docker run -v $script_path/../:/app \
  debian:stretch /app/bin/gen-iso.sh
