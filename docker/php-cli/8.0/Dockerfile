FROM php:8.0-cli

LABEL de.sandstein.dde="php"

ENV LANG=C.UTF-8

COPY files/usr/local/bin /usr/local/bin

RUN set -x \
    && apt-update \
    && apt-install \
        apt-transport-https \
        ca-certificates \
        locales \
        gnupg \
        procps \
        wget \
        curl \
        vim \
        net-tools \
        tzdata \
        zip \
        unzip \
        bzip2 \
        moreutils \
        dnsutils \
        openssh-client \
        rsync \
        git \
        git-flow \
        patch \
        bash-completion \
        # add mysqlclient to be able to access mysql from cli
        mariadb-client > /dev/null \
    && /usr/local/bin/generate-locales > /dev/null \
    && docker-image-cleanup > /dev/null

# install npm
RUN set -x \
    && apt-update  > /dev/null\
    && apt-install \
        nodejs \
        npm

ADD https://github.com/mlocati/docker-php-extension-installer/releases/download/2.13.2/install-php-extensions /usr/local/bin/

RUN set -x \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions \
      amqp \
      apcu \
      bcmath \
      bz2 \
      calendar \
      exif \
      gd \
      geospatial \
      gettext \
      gmagick \
      gnupg \
      grpc \
      imap \
      intl \
      ldap \
      lzf \
      mailparse \
      mcrypt \
      memcache \
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
      solr \
      sourceguardian \
      sysvmsg \
      sysvsem \
      sysvshm \
      tidy \
      timezonedb \
      xdebug \
      xhprof \
      xlswriter \
      xmlrpc \
      xsl \
      zip \
      zstd > /dev/null \
    && docker-image-cleanup

RUN groupadd -g 1000 phpcli && \
    useradd -u 1000 -g 1000 -m -s /bin/bash phpcli

RUN mkdir -p /home/phpcli/.config /home/phpcli/.ssh \
    && chmod 700 /home/phpcli/.ssh \
    && chown -R phpcli:phpcli /home/phpcli
