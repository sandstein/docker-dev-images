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
# extensions to leave out for this version, e.g. not yet supported by the installer (docker-bake.hcl)
ARG SKIP_EXTENSIONS=""

FROM php:${VERSION}-${TYPE} AS common

LABEL de.sandstein.dde="php"

ENV LANG=C.UTF-8

COPY files/usr/local/bin /usr/local/bin

RUN install-dev-tools

# pinned, update together with the extension lists if needed
ARG INSTALLER_VERSION=2.13.2
ADD https://github.com/mlocati/docker-php-extension-installer/releases/download/${INSTALLER_VERSION}/install-php-extensions /usr/local/bin/

ARG EXTENSIONS=""
ARG SKIP_EXTENSIONS
RUN chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions-except "${SKIP_EXTENSIONS}" \
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
ARG SKIP_EXTENSIONS
RUN install-php-extensions-except "${SKIP_EXTENSIONS}" solr sourceguardian ${CLI_EXTENSIONS} \
    && docker-image-cleanup

# no VOLUME for the home directory: dde bind-mounts ~/.config and ~/.ssh
RUN groupadd -g 1000 phpcli \
    && useradd -u 1000 -g 1000 -m -s /bin/bash phpcli \
    && mkdir -p /home/phpcli/.config /home/phpcli/.ssh \
    && chmod 700 /home/phpcli/.ssh \
    && chown -R phpcli:phpcli /home/phpcli

FROM cli AS cli-prod
RUN cp "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"

# Deployment image for GitLab CI jobs (sandstein/php-deploy:<version>): runs as gitlab-runner
# (UID/GID 999), ships composer, deployer (dep) and node (Debian nodejs on PATH, nvm LTS for
# shells that source nvm).
FROM composer:2 AS composer

FROM cli-prod AS deploy

LABEL de.sandstein.deploy="php"

COPY files/php/deploy.ini "${PHP_INI_DIR}/conf.d/zz-deploy.ini"

RUN install-dev-tools nodejs npm

RUN usermod -l gitlab-runner -d /home/gitlab-runner -m phpcli \
    && groupmod -n gitlab-runner phpcli \
    && modify-user-ids gitlab-runner 999 999 \
    && mkdir -p /home/gitlab-runner/bin /home/gitlab-runner/.ssh \
    && chmod 700 /home/gitlab-runner/.ssh

COPY --from=composer /usr/bin/composer /home/gitlab-runner/bin/composer
RUN chown -R gitlab-runner:gitlab-runner /home/gitlab-runner

ENV PATH="/home/gitlab-runner/bin:${PATH}"
USER gitlab-runner:gitlab-runner
WORKDIR /home/gitlab-runner

# pinned major (set per PHP version in docker-bake.hcl): the weekly rebuild must not switch
# deployer majors under running projects
ARG DEPLOYER_VERSION=^8
ARG NVM_VERSION=v0.40.4
RUN composer global require "deployer/deployer:${DEPLOYER_VERSION}" \
    && ln -s ../.composer/vendor/bin/dep bin/dep \
    && composer clear-cache \
    && wget -qO- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash \
    && export NVM_DIR="${HOME}/.nvm" \
    && . "${NVM_DIR}/nvm.sh" --no-use \
    && nvm install --lts \
    && nvm cache clear

FROM cli AS cli-dev
ARG SKIP_EXTENSIONS
RUN install-dev-tools nodejs npm \
    && install-php-extensions-except "${SKIP_EXTENSIONS}" xdebug xhprof \
    && docker-image-cleanup


# --- fpm ---------------------------------------------------------------------

FROM common AS fpm-prod
RUN cp "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"

FROM common AS fpm-dev
ARG SKIP_EXTENSIONS
RUN install-php-extensions-except "${SKIP_EXTENSIONS}" xdebug xhprof \
    && docker-image-cleanup
