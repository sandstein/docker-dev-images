FROM php:7.3-cli

LABEL de.sandstein.dde="php"

COPY files/usr/local/bin /usr/local/bin

RUN set -x \
    && apt-update > /dev/null \
    && apt-install > /dev/null \
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
        patch \
        # add mysqlclient to be able to access mysql from cli
        mariadb-client > /dev/null \
    && /usr/local/bin/generate-locales > /dev/null \
    && docker-image-cleanup > /dev/null

ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

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
      geoip \
      geospatial \
      gettext \
      gmagick \
      gnupg \
      grpc \
      imap \
      intl \
      ioncube_loader \
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
    && docker-image-cleanup > /dev/null

RUN groupadd -g 1000 phpcli && \
    useradd -u 1000 -g 1000 -m -s /bin/bash phpcli

VOLUME /home/phpcli/.ssh /home/phpcli/.config
