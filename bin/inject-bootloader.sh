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
losetup -o $(expr 512 \* 2048) /dev/loop0 $img_file
mkdir /mnt/img
mount -t auto /dev/loop0 /mnt/img

extlinux --install /mnt/img/boot/

umount /mnt/img
losetup -d /dev/loop0

