FROM archlinux:base-20210613.0.25781

# Mkinitcpio autodetect hook removed 
# because it try to load fsck.overlay 
# when launched inside a docker container

COPY etc/mkinitcpio.conf /etc/

RUN pacman-key --init \
  && pacman --noconfirm -Suy \
     pacman --noconfirm base linux \
  && echo "root:root" | chpasswd

COPY etc/syslinux.cfg /boot/
