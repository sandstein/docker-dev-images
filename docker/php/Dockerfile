# PHP cli and fpm images for all maintained versions.
#
# Build targets (selected by docker-bake.hcl):
#   cli-dev / fpm-dev    sandstein/php:<type>-<version>        xdebug, xhprof (+ node/npm for cli)
#   cli-prod / fpm-prod  sandstein/php:<type>-<version>-prod   no debugger/profiler/node, php.ini-production
#
# VERSION and TYPE pick the upstream image; EXTENSIONS and CLI_EXTENSIONS add the
# version specific extensions on top of the common list below (see docker-bake.hcl).

ARG VERSION=8.5
ARG TYPE=cli

FROM php:${VERSION}-${TYPE} AS common

LABEL de.sandstein.dde="php"

ENV LANG=C.UTF-8

COPY files/usr/local/bin /usr/local/bin

RUN install-dev-tools

# pinned, update together with the extension lists if needed
ARG INSTALLER_VERSION=2.13.2
ADD https://github.com/mlocati/docker-php-extension-installer/releases/download/${INSTALLER_VERSION}/install-php-extensions /usr/local/bin/

ARG EXTENSIONS=""
RUN chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions \
      amqp \
      apcu \
      bcmath \
      bz2 \
      calendar \
      exif \
      ftp \
      gd \
      geospatial \
      gettext \
      gnupg \
      grpc \
      imagick \
      imap \
      intl \
      ldap \
      lzf \
      mailparse \
      memcached \
      mongodb \
      mysqli \
      oauth \
      odbc \
      opcache \
      pcntl \
      pdo_mysql \
      pdo_odbc \
      pdo_pgsql \
      pgsql \
      redis \
      shmop \
      soap \
      sockets \
      sysvmsg \
      sysvsem \
      sysvshm \
      tidy \
      timezonedb \
      xlswriter \
      xmlrpc \
      xsl \
      zip \
      zstd \
      ${EXTENSIONS} \
    && docker-image-cleanup


# --- cli ---------------------------------------------------------------------

FROM common AS cli

RUN install-dev-tools \
        git-flow \
        ghostscript \
        bash-completion \
        mariadb-client

ARG CLI_EXTENSIONS=""
RUN install-php-extensions solr sourceguardian ${CLI_EXTENSIONS} \
    && docker-image-cleanup

# no VOLUME for the home directory: dde bind-mounts ~/.config and ~/.ssh
RUN groupadd -g 1000 phpcli \
    && useradd -u 1000 -g 1000 -m -s /bin/bash phpcli \
    && mkdir -p /home/phpcli/.config /home/phpcli/.ssh \
    && chmod 700 /home/phpcli/.ssh \
    && chown -R phpcli:phpcli /home/phpcli

FROM cli AS cli-prod
RUN cp "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"

FROM cli AS cli-dev
RUN install-dev-tools nodejs npm \
    && install-php-extensions xdebug xhprof \
    && docker-image-cleanup


# --- fpm ---------------------------------------------------------------------

FROM common AS fpm-prod
RUN cp "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"

FROM common AS fpm-dev
RUN install-php-extensions xdebug xhprof \
    && docker-image-cleanup
