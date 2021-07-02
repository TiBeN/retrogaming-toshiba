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
part_size_mbytes=2500
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
mount /dev/loop0p1 /mnt

echo Prepare ArchLinux filesystem

pacstrap /mnt base linux intel-ucode grub 

# Additional things for debug
pacstrap /mnt virtualbox-guest-utils openssh vim wpa_supplicant

arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
arch-chroot /mnt hwclock --systohc
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
echo "KEYMAP=fr-latin1" > /mnt/etc/vconsole.conf
echo "arcade" > /mnt/etc/hostname
cat << EOF > /mnt/etc/hosts
127.0.0.1 localhost
::1   localhost
127.0.1.1 arcade.localdomain  arcade
EOF
echo "root:root" | chpasswd -R /mnt
arch-chroot /mnt useradd -m arcade
echo "arcade:arcade" | chpasswd -R /mnt

# Theses have to be installed after locales configuration
# (especially libx11) and using normal pacman tool because of obscure 
# bug: <https://bbs.archlinux.org/viewtopic.php?id=250846>
arch-chroot /mnt pacman --noconfirm -S xorg-server xorg-xinit xterm \
  openbox ttf-dejavu ttf-liberation mesa mesa-demos qt5-base \
  sdl2 alsa-lib flac zlib ffmpeg v4l-utils libx11

mkdir /mnt/boot/grub 
cat > /mnt/boot/grub/loop0device.map <<EOF
(hd0) /dev/loop0
EOF
grub-install --no-floppy --grub-mkdevicemap=loop0device.map \
  --modules="part_msdos" --boot-directory=/mnt/boot /dev/loop0

# Inject EDID and Configure Kernel boot parameters
mkdir -p /mnt/lib/firmware/edid
cp $script_path/../share/edid/crt.bin /mnt/lib/firmware/edid/
sed -i 's#GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"#GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 video=LVDS-1:d video=SVIDEO-1:d video=TV-1:d video=DP-1:d video=VGA-1:e drm_kms_helper.edid_firmware=VGA-1:edid/crt.bin"#g' /mnt/etc/default/grub

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

# Prepare Xorg
arch-chroot /mnt usermod -aG tty arcade
cat > /mnt/etc/X11/Xwrapper.config <<EOF
allowed_users=anybody
needs_root_rights=yes
EOF
chmod u+s /mnt/usr/lib/Xorg.wrap

# Enable network
arch-chroot /mnt systemctl enable systemd-networkd.service
arch-chroot /mnt systemctl enable systemd-resolved.service
arch-chroot /mnt systemctl enable wpa_supplicant@wlp20s0.service
arch-chroot /mnt systemctl enable sshd.service

cat > /mnt/etc/systemd/network/20-wired.network <<EOF
[Match]
Name=enp0s3

[Network]
DHCP=yes
EOF

cat > /mnt/etc/systemd/network/20-wifi.network <<EOF
[Match]
Name=wlp20s0

[Network]
DHCP=yes
EOF

cat > /mnt/etc/wpa_supplicant/wpa_supplicant-wlp20s0.conf <<EOF
network={
  ssid="SFR_4568"
  psk="drotogratchestra9wfi"
  priority=5
}
EOF

# Inject built items (RA etc.)
rm -rf /build/usr/local/share/man
cp -r /build/* /mnt/

# Inject additional files
cp -r /app/share/inject/* /mnt/

# (DEBUG) create some launchers for testing purposes
mkdir -p /mnt/usr/local/bin
echo 'exec retroarch -L /usr/local/lib/libretro/snes9x_libretro.so "/usr/local/share/roms/Mr. Nutz (USA) (En,Fr).zip"' > /mnt/usr/local/bin/ra-mrnutz
chmod +x /mnt/usr/local/bin/ra-mrnutz
echo 'exec retroarch -L /usr/local/lib/libretro/genesis_plus_gx_libretro.so "/usr/local/share/roms/Sonic The Hedgehog 2 (World).zip"' > /mnt/usr/local/bin/ra-sonic2
chmod +x /mnt/usr/local/bin/ra-sonic2
echo 'exec retroarch -L /usr/local/lib/libretro/mednafen_pce_libretro.so "/usr/local/share/roms/Magical Chase (USA).zip"' > /mnt/usr/local/bin/ra-magchase
chmod +x /mnt/usr/local/bin/ra-magchase
echo 'exec retroarch -L /usr/local/lib/libretro/nestopia_libretro.so "/usr/local/share/roms/Super Mario Bros. (World).zip"' > /mnt/usr/local/bin/ra-smb
chmod +x /mnt/usr/local/bin/ra-smb

echo Unmount image

umount /mnt
losetup -d /dev/loop0
