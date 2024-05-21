# syntax=docker/dockerfile:1
ARG SABNZBD_VERSION="4.3.1-ls162"

FROM sandreas/ffmpeg:5.0.1-3 as ffmpeg
FROM sandreas/tone:v0.1.6 as tone
FROM sandreas/mp4v2:2.1.1 as mp4v2
FROM sandreas/fdkaac:2.0.1 as fdkaac

FROM ghcr.io/linuxserver/sabnzbd:${SABNZBD_VERSION}

RUN echo "---- INSTALL RUNTIME PACKAGES ----" && \
  apk add --no-cache --update --upgrade \
  # mp4v2: required libraries
  libstdc++ \
  # m4b-tool: php cli, required extensions and php settings
  php83 \
  php83-dom \
  php83-xml \
  php83-mbstring \
  php83-phar \
  php83-tokenizer \
  php83-xmlwriter \
  php83-openssl \
  && ln -s /usr/bin/php83 /bin/php

COPY --from=ffmpeg /usr/local/bin/ffmpeg /usr/local/bin/
COPY --from=tone /usr/local/bin/tone /usr/local/bin/
COPY --from=mp4v2 /usr/local/bin/mp4* /usr/local/bin/
COPY --from=mp4v2 /usr/local/lib/libmp4v2* /usr/local/lib/
COPY --from=fdkaac /usr/local/bin/fdkaac /usr/local/bin/

ARG M4B_TOOL_DOWNLOAD_LINK="https://github.com/sandreas/m4b-tool/releases/latest/download/m4b-tool.tar.gz"

RUN wget "${M4B_TOOL_DOWNLOAD_LINK}" -O /tmp/m4b-tool.tar.gz && \
  tar -xzf /tmp/m4b-tool.tar.gz -C "/tmp/" && \
  mv "/tmp/m4b-tool.phar" /usr/local/bin/m4b-tool && \
  chmod +x /usr/local/bin/m4b-tool && \
  rm -rf /tmp/m4b-tool.tar.gz


