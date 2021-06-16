#!/bin/bash
#
# Build system iso image

set -e

script_path=$(readlink -f `dirname $0`)

# Generate file system as Docker image

docker build -t retrogaming-filesystem $script_path/../ --file os-arch.Dockerfile

# Extract Docker image filesystem

container_id=$(docker run -d retrogaming-filesystem /bin/true)
docker export -o $script_path/../var/tmp/filesystem.tar $container_id
docker container rm $container_id 

# Generate builder image
docker build -t retrogaming-iso-builder $script_path/../ --file builder.Dockerfile

# Generate partitionned ISO image containing filesystem data

docker run --rm -v $script_path/../:/app \
  --user 1000:1000 \
  retrogaming-iso-builder:latest \
  /app/bin/gen-iso.sh

# Inject bootloader into ISO image
# Done in separate instance because this process
# needs special rights to mount image as loop device

docker run --rm -v $script_path/../:/app \
  --cap-add SYS_ADMIN \
  --device-cgroup-rule="b 7:* rmw" \
  retrogaming-iso-builder:latest \
  /app/bin/inject-bootloader.sh

# Generate Virtualbox image from Raw iso image

docker run --rm -v $script_path/../:/app \
  --user 1000:1000 \
  retrogaming-iso-builder:latest \
  vboxmanage convertfromraw --format vdi /app/build/retrogaming.iso /app/build/retrogaming.vdi
