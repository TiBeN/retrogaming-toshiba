# ISO image file system and assets builder

FROM archlinux:base-20210613.0.25781

ARG number_cpus=3

RUN pacman-key --init \
  && pacman --noconfirm -Suy \
  && pacman --noconfirm -S arch-install-scripts virtualbox \
    grub git base-devel xorg-server-devel mesa freetype2 \
    ffmpeg flac zlib nasm sfml libarchive curl openal glu

WORKDIR /usr/local/src

# Build RetroArch
# As explain here: <https://docs.libretro.com/development/retroarch/compilation/linux-and-bsd/>
RUN git clone --depth 1 --branch v1.9.6 https://github.com/libretro/RetroArch.git
RUN cd /usr/local/src/RetroArch \
  && ./configure \
  && make -j${number_cpus} \
  && make DESTDIR=/build install

# Build libretro cores
RUN mkdir -p /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/libretro-atari800.git \
  && cd /usr/local/src/libretro-atari800 \
  && git checkout b59fb7e92577b734cfdd7b73bfc9821bfab247c2 \
  && make -j${number_cpus} \
  && cp atari800_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/blueMSX-libretro.git \
  && cd /usr/local/src/blueMSX-libretro \
  && git checkout 3204993bfc782a0db89afdcdb6d55cdac3e0f493 \
  && make -j${number_cpus} -f Makefile.libretro \
  && cp bluemsx_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/libretro-cap32.git \
  && cd /usr/local/src/libretro-cap32 \
  && git checkout 408da091504dabe9678b25b7a6c3bbef0bc4c140 \
  && make -j${number_cpus} \
  && cp cap32_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/dosbox-svn.git \
  && cd /usr/local/src/dosbox-svn/libretro \
  && git submodule update --init \
  && git checkout 09d51778a98ccb5e798b7045ddee2323f3681ef2 \
  && make -j${number_cpus} -f Makefile.libretro target=x86 WITH_FAKE_SDL=1 \
  && cp dosbox_svn_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/FBNeo.git \
  && cd /usr/local/src/FBNeo/src/burner/libretro \
  && git checkout 1779a86fa60b8cf268b9e65c868ae28c2b9e7b21 \
  && make -j${number_cpus} \
  && cp fbneo_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/libretro-fceumm.git \
  && cd /usr/local/src/libretro-fceumm \
  && git checkout 152198515cb52ca9f92f4c792cd4ec9caff85b8f \
  && make -j${number_cpus} -f Makefile.libretro \
  && cp fceumm_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/FFmpeg.git \
  && cd /usr/local/src/FFmpeg/libretro \
  && git checkout 4920879d2f09a78cdf855403c349457cee1c31da \
  && make -j${number_cpus} \
  && cp ffmpeg_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/FreeIntv.git \
  && cd /usr/local/src/FreeIntv \
  && git checkout 5fc8d85ee9699baaaf0c63399c364f456097fc1e \
  && make -j${number_cpus} \
  && cp freeintv_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/fuse-libretro.git \
  && cd /usr/local/src/fuse-libretro \
  && git checkout 5b1c05330e907556d99a8caca769ce273fdc9198 \
  && make -j${number_cpus} \
  && cp fuse_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/gambatte-libretro.git \
  && cd /usr/local/src/gambatte-libretro \
  && git checkout 94221ec7037ff880e7977313bccdc8c0ee7ae679 \
  && make -j${number_cpus} \
  && cp gambatte_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/Genesis-Plus-GX.git \
  && cd /usr/local/src/Genesis-Plus-GX \
  && git checkout e8eb9f214f54ad813a3745b25dd6d5adc66c17ea \
  && make -j${number_cpus} -f Makefile.libretro \
  && cp genesis_plus_gx_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/libretro-handy.git \
  && cd /usr/local/src/libretro-handy \
  && git checkout aceb3ee169f2467eaa42906ba8dd06ecdaf6e6c4 \
  && make -j${number_cpus} \
  && cp handy_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/hatari.git \
  && cd /usr/local/src/hatari \
  && git checkout cea06eebf695b078fadc0e78bb0f2b2baaca799f \
  && make -j${number_cpus} -f Makefile.libretro \
  && cp hatari_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/neocd_libretro.git \
  && cd /usr/local/src/neocd_libretro \
  && git checkout ffa5ae0e853a30e87edb33bfaa5aadb86bf3058c \
  && make -j${number_cpus} \
  && cp neocd_libretro.so /build/usr/local/lib/libretro

# Mame can't compile with more than one CPU (no make -j)
RUN git clone https://github.com/libretro/mame.git \
  && cd /usr/local/src/mame \
  && git checkout 98b0ba18a9109339c2ebf4f5945f6c3575301ba9 \
  && make -f Makefile.libretro \ 
  && cp mame_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/beetle-gba-libretro.git \
  && cd /usr/local/src/beetle-gba-libretro \
  && git checkout ed957ff355e67769a9e0d3b872cbd6f251e5cecc \
  && make -j${number_cpus} \
  && cp mednafen_gba_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/beetle-lynx-libretro.git \
  && cd /usr/local/src/beetle-lynx-libretro \
  && git checkout 26cb625d1f1c27137ce8069d155231f5a5c68bda \
  && make -j${number_cpus} \
  && cp mednafen_lynx_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/beetle-ngp-libretro.git \
  && cd /usr/local/src/beetle-ngp-libretro \
  && git checkout 1a2dd95b4397cc05548ef81a9666c477c860e3ee \
  && make -j${number_cpus} \
  && cp mednafen_ngp_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/beetle-pce-libretro.git \
  && cd /usr/local/src/beetle-pce-libretro \
  && git checkout 0a4c18e1622c384813f26c62629542ce8ee78ecf \
  && make -j${number_cpus} \
  && cp mednafen_pce_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/beetle-pce-fast-libretro.git \
  && cd /usr/local/src/beetle-pce-fast-libretro \
  && git checkout 9f4435dd4b318eca44b3fe1e023d09c1c5dbacf8 \
  && make -j${number_cpus} \
  && cp mednafen_pce_fast_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/beetle-pcfx-libretro.git \
  && cd /usr/local/src/beetle-pcfx-libretro \
  && git checkout 67573ce2d4eec9cec1e368688f618be807b465d8 \
  && make -j${number_cpus} \
  && cp mednafen_pcfx_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/beetle-psx-libretro.git \
  && cd /usr/local/src/beetle-psx-libretro \
  && git checkout 78f4e82eca4540c99089a307d1ab1ae9711f35d2 \
  && make -j${number_cpus} HAVE_LIGHTREC=1 \
  && cp mednafen_psx_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/beetle-saturn-libretro.git \
  && cd /usr/local/src/beetle-saturn-libretro \
  && git checkout ee5b2140011063f728792efdead0ac9175984e26 \
  && make -j${number_cpus} \
  && cp mednafen_saturn_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/beetle-supergrafx-libretro.git \
  && cd /usr/local/src/beetle-supergrafx-libretro \
  && git checkout 7a84c5e3b9e0dc44266d3442130296888f3c573a \
  && make -j${number_cpus} \
  && cp mednafen_supergrafx_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/beetle-wswan-libretro.git \
  && cd /usr/local/src/beetle-wswan-libretro \
  && git checkout 663101e8ed47abfc34d8808fb6c2d78b128fa9b1 \
  && make -j${number_cpus} \
  && cp mednafen_wswan_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/mgba.git \
  && cd /usr/local/src/mgba \
  && git checkout eb3ddbe4c4cf9ff0ad7c578e70ed1d78af455bd4 \
  && make -j${number_cpus} -f Makefile.libretro \
  && cp mgba_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/nestopia.git \
  && cd /usr/local/src/nestopia/libretro \
  && git checkout c924b9d2cf8918b42fa1fa7db073a07a04e0c8cc \
  && make -j${number_cpus} \
  && cp nestopia_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/pcsx_rearmed.git \
  && cd /usr/local/src/pcsx_rearmed \
  && git checkout 31d1b18ba0408c684eaa63ce4be3b55d7e4b2aac \
  && make -j${number_cpus} -f Makefile.libretro DYNAREC=lightrec \
  && cp pcsx_rearmed_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/libretro-uae.git \
  && cd /usr/local/src/libretro-uae \
  && git checkout 283ab682266dc71c236fbbe67013504a410f26a9 \
  && make -j${number_cpus} \
  && cp puae_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/px68k-libretro.git \
  && cd /usr/local/src/px68k-libretro \
  && git checkout 0c02761b917585da13e754d14325b452bcb60d7a \
  && make -j${number_cpus} -f Makefile.libretro \
  && cp px68k_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/flycast.git \
  && cd /usr/local/src/flycast \
  && git checkout 8e4fa54e26232d6d54d3b0adca163ae7e617b9bd \
  && make -j${number_cpus} \
  && cp flycast_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/snes9x.git \
  && cd /usr/local/src/snes9x/libretro \
  && git checkout 937c177ef5c8a5d8e535d00d28acf7125593b4ba \
  && make -j${number_cpus} \
  && cp snes9x_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/stella-emu/stella.git \
  && cd /usr/local/src/stella/src/libretro \
  && git checkout 43a813958a73d1b5f42c7a4b321d0d63347a5a93 \
  && make -j${number_cpus} \
  && cp stella_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/vice-libretro.git \
  && cd /usr/local/src/vice-libretro \
  && git checkout 3e60783ac88101584122947d85157b74ff9a30a0 \
  && make -j${number_cpus} \
  && cp vice_x64_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/virtualjaguar-libretro.git \
  && cd /usr/local/src/virtualjaguar-libretro \
  && git checkout 2069160f316d09a2713286bd9bf4d5c2805bd143 \
  && make -j${number_cpus} \
  && cp virtualjaguar_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/yabause.git \
  && cd /usr/local/src/yabause/yabause/src/libretro \
  && git checkout 4d85b6e793030c77ae6b64fd7c99041c935b54ac \
  && make -j${number_cpus} \
  && cp yabause_libretro.so /build/usr/local/lib/libretro

RUN git clone https://github.com/libretro/mupen64plus-libretro-nx.git \
  && cd /usr/local/src/mupen64plus-libretro-nx \
  && git checkout b4024d75597da162bbc7cb693b8cef0d6da75105 \
  && make -j${number_cpus} WITH_DYNAREC=x86_64 HAVE_PARALLEL_RDP=1 HAVE_PARALLEL_RSP=1 HAVE_THR_AL=1 HAVE_LLE=1 \
  && cp mupen64plus_next_libretro.so /build/usr/local/lib/libretro

# Build attract mode
RUN git clone --depth 1 --branch v2.6.1 https://github.com/mickelson/attract.git \
  && cd /usr/local/src/attract \
  && make -j${number_cpus} \
  && make install prefix=/build/usr/local
