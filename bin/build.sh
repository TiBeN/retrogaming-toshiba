#!/bin/bash
#
# Build system ISO image

set -e

script_path=$(readlink -f `dirname $0`)

# Build Assets inside a Docker image

# To be implemented #

# Generate builder image

docker build -t retrogaming-iso-builder $script_path/../ --file builder.Dockerfile

# Generate and configure base Arch Linux system ISO 
#
# Note: Mounting /dev and use --priviledged is 
# required for mounting the iso but is it not a safe approach.
# Another solution should be found for that

docker run --rm -v $script_path/../:/app \
  -v /dev:/dev \
  --privileged \
  retrogaming-iso-builder:latest \
  /app/bin/gen-iso.sh

# Generate Virtualbox image from Raw ISO image

rm -rf build/retrogaming.vdi
docker run --rm -v $script_path/../:/app \
  --user 1000:1000 \
  retrogaming-iso-builder:latest \
  vboxmanage convertfromraw --format vdi /app/build/retrogaming.iso /app/build/retrogaming.vdi
