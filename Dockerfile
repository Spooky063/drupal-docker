ARG PHP_VERSION=7.4
ARG NGINX_VERSION=1.17

# "php" stage
FROM php:${PHP_VERSION}-fpm-alpine AS drupal_php

RUN apk add --no-cache \
        acl \
        fcgi \
        file \
        gettext \
        git \
        jq \
    ;

ARG APCU_VERSION=5.1.18
RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
	    $PHPIZE_DEPS \
	    icu-dev \
	    libzip-dev \
	    zlib-dev \
        coreutils \
        freetype-dev \
        libjpeg-turbo-dev \
        libwebp-dev \
        libpng-dev \
        postgresql-dev \
	; \
    \
	docker-php-ext-configure gd \
            --enable-gd \
            --with-freetype \
            --with-jpeg \
            --with-webp \
	; \
    \
	docker-php-ext-install -j$(nproc) \
	    intl \
	    zip \
	    gd \
        pdo_mysql \
        pdo_pgsql \
	; \
    \
	pecl install \
	    apcu-${APCU_VERSION} \
	; \
	pecl clear-cache; \
    \
	docker-php-ext-enable \
	    apcu \
	    opcache \
	; \
    \
	runDeps="$( \
	    scanelf --needed --nobanner --format '%n#p' --recursive /usr/local/lib/php/extensions \
	        | tr ',' '\n' \
	        | sort -u \
	        | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache --virtual .phpexts-rundeps $runDeps; \
	apk del .build-deps

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_MEMORY_LIMIT=-1
ENV PATH="${PATH}:/root/.composer/vendor/bin"

RUN ln -s $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini
COPY docker/php/conf.d/drupal.ini $PHP_INI_DIR/conf.d/drupal.ini

RUN set -eux; \
	{ \
		echo '[www]'; \
		echo 'ping.path = /ping'; \
	} | tee /usr/local/etc/php-fpm.d/docker-healthcheck.conf

WORKDIR /srv/app

ARG APP_ENV=prod

ARG STABILITY="dev"
ENV STABILITY ${STABILITY:-dev}

ARG DRUPAL_VERSION=""
RUN composer create-project "drupal-composer/drupal-project ${DRUPAL_VERSION}" . --stability=$STABILITY --prefer-dist --no-dev --no-progress --no-scripts --no-interaction; \
	composer clear-cache

COPY . .

COPY docker/php/docker-healthcheck.sh /usr/local/bin/docker-healthcheck
RUN chmod +x /usr/local/bin/docker-healthcheck

HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["docker-healthcheck"]

COPY docker/php/docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]

# "nginx" stage
FROM nginx:${NGINX_VERSION}-alpine AS drupal_nginx

COPY docker/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf

WORKDIR /srv/app

COPY --from=drupal_php /srv/app/web web/
