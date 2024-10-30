FROM python:3.10.12-slim-bullseye

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /uniqueizer

RUN apt-get update && apt-get install -y wget cmake autoconf automake nasm  \
    git-core libass-dev libfreetype6-dev libgnutls28-dev libmp3lame-dev libsdl2-dev \
    libva-dev libvdpau-dev  texinfo zlib1g-dev build-essential libtool pkg-config  \
    libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev meson ninja-build \
    libx264-dev libx265-dev libnuma-dev exiftool subversion;

RUN wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master \
    && tar xzvf fdk-aac.tar.gz && cd mstorsjo-fdk-aac* && autoreconf -fiv \
    && ./configure --prefix="$HOME/ffmpeg_build" --disable-shared && make && make install;

RUN wget -O ffmpeg-6.1.1.tar.xz https://ffmpeg.org/releases/ffmpeg-6.1.1.tar.xz \
    && tar xJf ffmpeg-6.1.1.tar.xz && cd ffmpeg-6.1.1 \
    && PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" \
    ./configure --enable-gpl --enable-libx264 --enable-libx265 --enable-libfdk-aac --enable-nonfree \
    --enable-libfreetype --enable-libharfbuzz --enable-libfontconfig --enable-libfribidi \
    && make && make install && rm /uniqueizer/ffmpeg-6.1.1.tar.xz;

RUN svn co https://svn.code.sf.net/p/gpac/code/trunk/gpac gpac; \
    cd gpac \
    && ./configure --disable-opengl --use-js=no --use-ft=no --use-jpeg=no --use-png=no --use-faad=no --use-mad=no --use-xvid=no --use-ffmpeg=no --use-ogg=no --use-vorbis=no --use-theora=no --use-openjpeg=no \
    && make \
    && make install \
    && cp bin/gcc/libgpac.so /usr/lib;


COPY poetry.lock pyproject.toml ./


RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install --no-cache-dir poetry \
    && poetry config virtualenvs.create false \
    && poetry install --without dev --no-interaction --no-ansi \
    && rm -rf $(poetry config cache-dir)/{cache,artifacts}

COPY . ./

CMD ["python3","core/main.py"]
