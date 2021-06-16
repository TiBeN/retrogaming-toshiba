#!/bin/bash
#
# Generate iso partitionned image for Docker exported tar file-system

set -e

script_path=$(readlink -f `dirname $0`)

# Extract filesystem for tar archive

echo Extract tar file

tar_file=$script_path/../var/tmp/filesystem.tar
filesystem_path=$script_path/../var/tmp/filesystem

rm -rf $filesystem_path 
mkdir $filesystem_path

tar -xf $tar_file -C $filesystem_path

# Prepare iso image partition

build_path=$script_path/../build
img_name=retrogaming.iso
img_file=$build_path/$img_name
mbyte=1048576
part_size_mbytes=800
part_size=$(($part_size_mbytes * $mbyte))
block_size=512
part_table_offset=$((2**20))
cur_offset=0
bs=1024

rm -rf $build_path && mkdir $build_path

echo Init image file, filling it with zeros

dd if=/dev/zero of="$img_file" bs="$bs" count=$((($part_table_offset + $part_size)/$bs)) skip="$(($cur_offset/$bs))"

echo Setup image file partition table

sfdisk $img_file <<EOF
label: dos
label-id: 0x5d8b75fc
device: new.img
unit: sectors

${img_name}1 : start=2048, size=$(($part_size/512)), type=83, bootable
EOF

echo Generate partition with filesystem data

part_file=$script_path/../build/${img_name}1

mke2fs -t ext4 \
  -d "$filesystem_path" \
  -r 1 \
  -N 0 \
  -m 5 \
  -L '' \
  -O ^64bit \
  "$part_file" \
  "${part_size_mbytes}M"

rm -r $filesystem_path 

echo Inject partition data to image

cur_offset=$(($cur_offset + $part_table_offset))
dd if="$part_file" of="$img_file" bs="$bs" seek="$(($cur_offset/$bs))"

rm -f $part_file

echo Inject Syslinux Master Boot Record

dd if=/usr/lib/syslinux/mbr/mbr.bin of="$img_file" bs=440 count=1 conv=notrunc
