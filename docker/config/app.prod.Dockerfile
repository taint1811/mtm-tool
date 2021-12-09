#FROM php:7.4-fpm-alpine
# v.25 fix php-fpm bug
FROM php:7.4.25-fpm-alpine
LABEL maintainer="Xcodi <xcodi.vn@gmail.com>"

ARG FOLDER_NAME

WORKDIR /data/www/${FOLDER_NAME}
RUN mkdir -p /data/www-logs

## Install Composer
RUN curl -sS https://getcomposer.org/installer \
  | php -- --install-dir=/usr/local/bin --filename=composer


## Install zip libraries and extension

RUN apk add --no-cache zip libzip-dev \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip

## Install intl library and extension
RUN apk add --no-cache icu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && rm -rf /var/cache/apk/*


## opcache 
RUN docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-install opcache


RUN docker-php-ext-install mysqli \
    && docker-php-ext-install pdo \
    && docker-php-ext-install pdo_mysql

# Install bcmath for short uuid
RUN docker-php-ext-install bcmath

# Install imagemagick
RUN set -ex \
    && apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS imagemagick-dev libtool \
    && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
    && pecl install imagick-3.4.3 \
    && docker-php-ext-enable imagick \
    && apk add --no-cache --virtual .imagick-runtime-deps imagemagick \
    && apk del .phpize-deps
    
### redis
RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

# gd, iconv
RUN apk add --update --no-cache freetype-dev libjpeg-turbo-dev libpng-dev libwebp-dev \
    && docker-php-ext-install iconv \
    && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-webp=/usr/include/ \
    && docker-php-ext-install gd

# apcu
RUN docker-php-source extract \
    && apk add --no-cache --virtual .phpize-deps-configure $PHPIZE_DEPS \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && apk del .phpize-deps-configure \
    && docker-php-source delete

### supervisor
# ENV SUPERVISOR_VERSION=4.2.0
# RUN apk add --update python3 py3-pip \
#     && \
#     pip install supervisor==$SUPERVISOR_VERSION
RUN apk --no-cache add \
        supervisor

COPY supervisor/supervisord.conf /etc/supervisord.conf
COPY supervisor/supervisord.conf /etc/supervisord.conf
COPY supervisor/entrypoint.sh /supervisor-entrypoint.sh
RUN chmod a+x /supervisor-entrypoint.sh

# gmp, bcmath
# RUN apk add --update --no-cache gmp gmp-dev \
#     && docker-php-ext-install gmp bcmath

# #----------ADD USER------------
RUN addgroup -g 1001 www
RUN adduser -D -u 1001 www -G www

# # Copy existing application directory permissions
COPY . /data/www/${FOLDER_NAME}

RUN chown -R www:www /data

# # Change current user to www
USER www

ENTRYPOINT [ "/supervisor-entrypoint.sh" ]