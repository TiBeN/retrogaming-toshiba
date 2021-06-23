# ISO Image builder

FROM archlinux:base-20210613.0.25781

RUN pacman-key --init \
  && pacman --noconfirm -Suy \
  && pacman --noconfirm -S arch-install-scripts virtualbox grub
