FROM registry.cn-hongkong.aliyuncs.com/dehim/alpine:2020.06.21

ENV DEBIAN_FRONTEND=noninteractive \
    PHP_VERSION=7.3.19 \
    ICU_VERSION=67-1

RUN apk add --no-cache --virtual .build-deps build-base shadow bash binutils linux-headers g++ gcc re2c make cmake autoconf automake \
           nasm gettext libtool binutils-gold gnupg libgcc python libxml2-dev 

RUN make -p /usr/src \
    && chmod -R 777 /usr/src 


# install intl-icu begin
RUN cd /usr/src \
    && wget https://github.com/unicode-org/icu/archive/release-${ICU_VERSION}.tar.gz \
    && tar -zxf release-${ICU_VERSION}.tar.gz \
    && cd icu-release-${ICU_VERSION}/icu4c/source \
    && ./configure --prefix=/usr/local/icu \
    && make && make install 
# install intl-icu end

    