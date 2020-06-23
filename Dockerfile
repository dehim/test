FROM registry.cn-hongkong.aliyuncs.com/dehim/alpine:2020.06.21

ENV DEBIAN_FRONTEND=noninteractive \
    PHP_VERSION=7.3.19 \
    ICU_VERSION=67-1

RUN apk add --no-cache --virtual .build-deps build-base shadow bash binutils linux-headers g++ gcc re2c make cmake autoconf automake \
           nasm gettext libtool binutils-gold gnupg libgcc python 

RUN addgroup www \
    && adduser -G www -D -s /bin/bash www \
    && make -p /usr/src \
    && chmod -R 777 /usr/src 


# install intl-icu begin
RUN cd /usr/src \
    && wget https://github.com/unicode-org/icu/archive/release-${ICU_VERSION}.tar.gz \
    && tar -zxf release-${ICU_VERSION}.tar.gz \
    && cd icu-release-${ICU_VERSION}/icu4c/source \
    && ./configure --prefix=/usr/local/icu \
    && make && make install 
# install intl-icu end

    
# install php begin
RUN cd /usr/src/ \
#    && apk add --no-cache --virtual .build-deps g++ re2c nasm gettext libtool make autoconf automake \
    && wget http://www.php.net/distributions/php-${PHP_VERSION}.tar.gz \
    && tar -zxf php-$PHP_VERSION.tar.gz && cd php-$PHP_VERSION \
    && ./configure \
       --prefix=/production/server/php \
       --with-config-file-path=/production/server/php/etc \
 #      --with-config-file-scan-dir=/production/server/php/etc/php.d \
       --with-config-file-scan-dir=/shareVolume/config/php.d \
       --disable-ipv6 \
       --enable-bcmath \
       --enable-calendar \
       --enable-exif \
       --enable-fpm \
       --with-fpm-user=www \
       --with-fpm-group=www \
       --enable-ftp \
       --enable-gd-jis-conv \
       --enable-inline-optimization \
       --enable-mbregex \
       --enable-mbstring \
       --enable-mysqlnd \
       --enable-opcache \
       --enable-pcntl \
       --enable-shmop \
       --enable-soap \
       --enable-sockets \
       --enable-static \
       --enable-sysvsem \
       --enable-wddx \
       --enable-xml \
       --enable-zip \
    #    --with-curl=/usr/local/curl \
       --with-curl=/usr \
       --with-gd=/usr \
       --with-jpeg-dir \
       --with-freetype-dir \
       --with-xpm-dir \
       --with-png-dir \
       --with-gettext \
#       --with-iconv=/usr/local/libiconv \
       --with-libxml-dir=/usr \
       --with-mhash \
       --with-openssl \
       --with-xmlrpc \
       --with-zlib-dir=/usr/local/lib64 \
#       --with-iconv-dir=/usr/local/libiconv \
#       --with-unixODBC=/usr \
#       --with-mysqli=mysqlnd \
#       --with-pdo-odbc=unixODBC,/usr \
#       --with-pdo-dblib=/usr/local/freetds \
#       --with-pdo-mysql=mysqlnd \
       --enable-intl \
       --with-icu-dir=/usr/local/icu \
       --without-pear \
       --disable-debug \
       --disable-phpdbg \
    && make && make install \
    && strip /production/server/php/bin/php \
    && strip /production/server/php/bin/php-cgi \
    && strip /production/server/php/sbin/php-fpm \
#    && apk del .build-deps \
#   && apk del build-base shadow binutils \
    && mkdir -p /production/server/php/etc/php.d \
    && echo "export PATH=\$PATH:/production/server/php/bin" >> ~/.bashrc \
    && echo "export PATH=\$PATH:/production/server/php/sbin" >> ~/.bashrc \
    && source ~/.bashrc 
#    && rm -rf /usr/src/* \
  # install php finish