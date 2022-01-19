FROM php:8.0-fpm

COPY files/usr/local/bin /usr/local/bin

RUN set -x \
    && apt-update \
    # Enable non-free
    && apt-update \
    # System update
    && /usr/local/bin/apt-upgrade \
    # Base stuff
    && apt-install \
        apt-transport-https \
        ca-certificates \
        locales \
        gnupg \
        procps

RUN set -x \
    # Install packages
    && apt-install \
        wget \
        curl \
        vim \
        net-tools \
        tzdata \
    && docker-image-cleanup

RUN set -x \
    # Install services
    && apt-install \
        # Install common tools
        zip \
        unzip \
        bzip2 \
        moreutils \
        dnsutils \
        openssh-client \
        rsync \
        git \
        patch \
    && /usr/local/bin/generate-locales \
    && docker-image-cleanup

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
      zstd \
    && docker-image-cleanup
