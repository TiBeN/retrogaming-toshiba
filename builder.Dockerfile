# ISO image and assets builder

FROM archlinux:base-20210613.0.25781

RUN pacman-key --init \
  && pacman --noconfirm -Suy \
  && pacman --noconfirm -S arch-install-scripts virtualbox grub git base-devel xorg-server-devel mesa freetype2 ffmpeg flac zlib

WORKDIR /usr/local/src

# Build RetroArch
# As explain here: <https://docs.libretro.com/development/retroarch/compilation/linux-and-bsd/>

ENV LIBRETRO_CORES="atari800 bluemsx bsnes cap32 dolphin dosbox_svn fbneo fceumm ffmpeg fmsx freeintv fuse gambatte genesis_plus_gx handy hatari neocd mame mednafen_gba mednafen_lynx mednafen_ngp mednafen_pce mednafen_pce_fast mednafen_pcfx mednafen_psx mednafen_saturn mednafen_supergrafx mednafen_wswan mgba mupen64plus_next nestopia parallel_n64 pcsx_rearmed puae px68k flycast snes9x stella vice_x64 virtualjaguar yabause"

RUN git clone git://github.com/libretro/libretro-super.git
WORKDIR /usr/local/src/libretro-super
RUN SHALLOW_CLONE=1 ./libretro-fetch.sh retroarch $LIBRETRO_CORES
RUN ./retroarch-build.sh
RUN ./libretro-build.sh $LIBRETRO_CORES

RUN mkdir -p /build/ra/cores
RUN cd retroarch && make DESTDIR=/build/ra install
RUN ./libretro-install.sh /build/ra/cores

# Build GroovyMame (for some fun..)

# Build attract mode
