FROM archlinux:base-20210613.0.25781

# Mkinitcpio autodetect hook removed 
# because it try to load fsck.overlay 
# when launched inside a docker container

RUN echo $UID


COPY etc/mkinitcpio.conf /etc/

RUN pacman-key --init \
  && pacman --noconfirm -Suy \
  && pacman --noconfirm -S arch-install-scripts \
  && pacstrap / base linux linux-firmware \
  && echo "root:root" | chpasswd \
  && ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime \
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && locale-gen \
  && echo "LANG=en_US.UTF-8" > /etc/locale.conf \
  && echo "KEYMAP=fr-latin1" > /etc/vconsole.conf \
  && systemctl enable NetworkManager.service \
  && useradd -m arcade \
  && echo "arcade:arcade" | chpasswd 

COPY etc/syslinux.cfg /boot/
