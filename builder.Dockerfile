# ISO Image builder

FROM debian:stretch

RUN echo "deb http://deb.debian.org/debian stretch-backports main contrib" > /etc/apt/sources.list.d/backports.list \
  && apt-get update -y \
  && apt-get -y install extlinux \
  && apt-get -y install virtualbox/stretch-backports
