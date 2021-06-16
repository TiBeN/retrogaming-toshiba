FROM debian:stretch

RUN apt-get -u update \
  && apt-get -y install --no-install-recommends \
    linux-image-amd64 \
    systemd-sysv

COPY etc/syslinux.cfg /boot/

RUN echo "root:root" | chpasswd