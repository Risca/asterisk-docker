# vim:set ft=dockerfile:
FROM debian:bullseye-slim

LABEL maintainer="Patrik Dahlström <risca@dalakolonin.se>"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get -qq install \
    asterisk asterisk-dev \
    libsndfile1 libsndfile1-dev \
    libsamplerate0 libsamplerate0-dev \
    espeak-ng libespeak-ng-dev \
    build-essential \
    wget \
  && rm -rf /var/lib/apt/lists/*

RUN cd /usr/lib/asterisk/modules \
  && wget -q "http://asterisk.hosting.lv/bin/codec_g723-ast160-gcc4-glibc-x86_64-core2-sse4.so" \
  && wget -q "http://asterisk.hosting.lv/bin/codec_g729-ast160-gcc4-glibc-x86_64-core2-sse4.so" \
  && wget -q "http://downloads.digium.com/pub/telephony/codec_siren14/asterisk-16.0/x86-64/codec_siren14-16.0_current-x86_64.tar.gz" \
  && tar --strip 1 -xf codec_siren14*.tar.gz --wildcards "*/codec_siren14.so" \
  && rm codec_siren14*.tar.gz

RUN wget -q "https://github.com/zaf/Asterisk-eSpeak/archive/refs/tags/v5.0-rc1.tar.gz" \
  && tar xf v5.0-rc1.tar.gz \
  && make -C Asterisk-eSpeak-5.0-rc1 install \
  && rm -rf Asterisk-eSpeak-5.0-rc1 v5.0-rc1.tar.gz

RUN apt-get -qq remove --purge \
    asterisk-dev \
    libsndfile1-dev \
    libsamplerate0-dev \
    libespeak-ng-dev \
    build-essential wget \
  && apt-get -qq autoremove --purge

EXPOSE 5060/udp 5060/tcp 5061/tcp
VOLUME /var/lib/asterisk/sounds /var/lib/asterisk/keys /var/lib/asterisk/phoneprov /var/spool/asterisk /var/log/asterisk

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/asterisk", "-vvvdddf", "-T", "-B", "-U", "asterisk", "-p"]
