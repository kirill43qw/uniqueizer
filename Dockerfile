FROM python:3.10.12-slim-bullseye

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /uniqueizer

RUN apt-get update && apt-get install -y wget cmake autoconf automake nasm  \
    git-core libass-dev libfreetype6-dev libgnutls28-dev libmp3lame-dev libsdl2-dev \
    libva-dev libvdpau-dev  texinfo zlib1g-dev build-essential libtool pkg-config  \
    libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev meson ninja-build \
    libx264-dev libx265-dev libnuma-dev exiftool;

RUN wget -O ffmpeg-6.1.1.tar.xz https://ffmpeg.org/releases/ffmpeg-6.1.1.tar.xz \
    && tar xJf ffmpeg-6.1.1.tar.xz && cd ffmpeg-6.1.1 \
    && ./configure --enable-gpl --enable-libx264 --enable-libx265  --enable-nonfree \
    --enable-libfreetype --enable-libharfbuzz --enable-libfontconfig --enable-libfribidi \
    && make && make install && rm /uniqueizer/ffmpeg-6.1.1.tar.xz;


COPY poetry.lock pyproject.toml ./


RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install --no-cache-dir poetry \
    && poetry config virtualenvs.create false \
    && poetry install --without dev --no-interaction --no-ansi \
    && rm -rf $(poetry config cache-dir)/{cache,artifacts}

COPY . ./

CMD ["python3","core/main.py"]
