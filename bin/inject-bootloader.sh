#!/bin/bash
#
# Inject bootloader into iso to make it runnable

set -e

script_path=$(readlink -f `dirname $0`)

build_path=$script_path/../build
img_name=retrogaming.iso
img_file=$build_path/$img_name

echo Inject Syslinux bootloader

mknod /dev/loop0 b 7 0
losetup -o 1048576 /dev/loop0 $img_file
mkdir /mnt/img
mount -t auto /dev/loop0 /mnt/img

extlinux --install /mnt/img/boot/

# Configure network has it is not possible inside docker container

echo "arcade" > /mnt/img/etc/hostname \
  && echo "127.0.0.1  localhost" >> /mnt/img/etc/hosts \
  && echo "::1    localhost" >> /mnt/img/etc/hosts \
  && echo "127.0.1.1  arcade.localdomain  arcade" >> /mnt/img/etc/hosts

umount /mnt/img
losetup -d /dev/loop0

