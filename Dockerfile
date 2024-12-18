# FROM debian:bookworm-slim AS ffmpeg
FROM ubuntu:22.04

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -qq update \
    && apt-get -qq install --no-install-recommends \
    build-essential \
    git \
    pkg-config \
    yasm \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/FFmpeg/FFmpeg.git --depth 1 --branch n6.1.1 --single-branch /FFmpeg-6.1.1

WORKDIR /FFmpeg-6.1.1

RUN PATH="$HOME/bin:$PATH" PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure \
      --prefix="$HOME/ffmpeg_build" \
      --pkg-config-flags="--static" \
      --extra-cflags="-I$HOME/ffmpeg_build/include" \
      --extra-ldflags="-L$HOME/ffmpeg_build/lib" \
      --extra-libs="-lpthread -lm" \
      --ld="g++" \
      --bindir="$HOME/bin" \
      --disable-doc \
      --disable-htmlpages \
      --disable-podpages \
      --disable-txtpages \
      --disable-network \
      --disable-autodetect \
      --disable-hwaccels \
      --disable-ffprobe \
      --disable-ffplay \
      --enable-filter=copy \
      --enable-protocol=file \
      --enable-small && \
    PATH="$HOME/bin:$PATH" make -j$(nproc) && \
    make install && \
    hash -r
RUN cp /FFmpeg-6.1.1/ffmpeg /usr/local/bin/ffmpeg
RUN rm -rf /FFmpeg-6.1.1

# FROM swaggerapi/swagger-ui:v5.9.1 AS swagger-ui

# FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

ENV PYTHON_VERSION=3.10
ENV POETRY_VENV=/app/.venv

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -qq update \
    && apt-get -qq install --no-install-recommends \
    && apt-get install -y git wget \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s -f /usr/bin/python${PYTHON_VERSION} /usr/bin/python3 && \
    ln -s -f /usr/bin/python${PYTHON_VERSION} /usr/bin/python && \
    ln -s -f /usr/bin/pip3 /usr/bin/pip

RUN python3 -m venv $POETRY_VENV \
    && $POETRY_VENV/bin/pip install -U pip==24.0 setuptools \
    && $POETRY_VENV/bin/pip install poetry==1.6.1

ENV PATH="${PATH}:${POETRY_VENV}/bin"

WORKDIR /app

COPY poetry.lock pyproject.toml ./

RUN poetry config virtualenvs.in-project true
RUN poetry install --no-root

RUN rm -rf /usr/share/dotnet \
    && rm -rf /opt/ghc \
    && rm -rf /usr/local/share/boost \
    && rm -rf "$AGENT_TOOLSDIRECTORY" \
    && rm -rf /var/lib/apt/lists/*

RUN pip install git+https://github.com/ahmetoner/whisper-asr-webservice.git

RUN pip install soundfile editdistance "numpy<2" tensorboardX

COPY . .

# RUN poetry install
RUN pip install torch==1.13.1+cu117 -f https://download.pytorch.org/whl/torch
RUN pip install git+https://github.com/huggingface/transformers.git

EXPOSE 9000

ADD entrypoint.sh /
RUN chmod +x entrypoint.sh

CMD [ "entrypoint.sh" ]
