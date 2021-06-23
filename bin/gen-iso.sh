#!/bin/bash
#
# Generate iso image with Base Arch Linux system inside

set -e

script_path=$(readlink -f `dirname $0`)

# Prepare ISO image partition

build_path=$script_path/../build/
img_name=retrogaming.iso
img_file=$build_path/$img_name
mbyte=1048576
part_size_mbytes=2000
part_size=$(($part_size_mbytes * $mbyte))
block_size=512
part_table_offset=$((2**20))
cur_offset=0
bs=1024

rm -rf $build_path/*

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

part_file=$build_path/${img_name}1

mke2fs -t ext4 \
  -r 1 \
  -N 0 \
  -m 5 \
  -L '' \
  -O ^64bit \
  "$part_file" \
  "${part_size_mbytes}M"

echo Inject partition data to image

cur_offset=$(($cur_offset + $part_table_offset))
dd if="$part_file" of="$img_file" bs="$bs" seek="$(($cur_offset/$bs))"

rm -f $part_file

chown 1000:1000 $img_file

echo Mount image 

losetup -fP $img_file
lsblk
mount /dev/loop0p1 /mnt

echo Prepare ArchLinux filesystem

pacstrap /mnt base linux grub
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
arch-chroot /mnt locale-gen
arch-chroot /mnt echo "LANG=en_US.UTF-8" > /etc/locale.conf
arch-chroot /mnt echo "KEYMAP=fr-latin1" > /etc/vconsole.conf
arch-chroot /mnt echo "arcade" > /etc/hostname
arch-chroot /mnt cat << EOF > /etc/hosts
127.0.0.1 localhost
::1   localhost
127.0.1.1 arcade.localdomain  arcade
EOF
echo "root:root" | chpasswd -R /mnt
arch-chroot /mnt useradd -m arcade
echo "arcade:arcade" | chpasswd -R /mnt

mkdir /mnt/boot/grub 

cat > /mnt/boot/grub/loop0device.map <<EOF
(hd0) /dev/loop0
EOF

grub-install --no-floppy --grub-mkdevicemap=loop0device.map \
  --modules="part_msdos" --boot-directory=/mnt/boot /dev/loop0

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

echo Unmount image

umount /mnt
losetup -d /dev/loop0
