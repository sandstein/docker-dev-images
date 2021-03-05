##############################################
#
# current version: 5.6.40
#
##############################################
FROM php:5.6-fpm

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

RUN set -x \
    # Install php environment
    && apt-install \
        # Install tools
        imagemagick \
        graphicsmagick \
        ghostscript \
        jpegoptim \
        libjpeg-turbo-progs \
        pngcrush \
        optipng \
        apngopt \
        pngnq \
        pngquant \
        # Libraries
        libldap-2.4-2 \
        libxslt1.1 \
        zlibc \
        zlib1g \
        libpq5 \
        libpng16-16 \
        libmcrypt4 \
        libzip4 \
        libjpeg62-turbo-dev \
        libfreetype6-dev \
        # Dev and headers
        libbz2-dev \
        libicu-dev \
        libldap2-dev \
        libldb-dev \
        libmcrypt-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        libmemcached-dev \
        libpng-dev \
        libpq-dev \
        libzip-dev \
        libc-client-dev \
        libkrb5-dev \
    # Install extensions
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install \
        bcmath \
        bz2 \
        calendar \
        exif \
        intl \
        imap \
        gettext \
        ldap \
        mysqli \
        mcrypt \
        hash \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        soap \
        sockets \
        tokenizer \
        sysvmsg \
        sysvsem \
        sysvshm \
        shmop \
        xmlrpc \
        xsl \
        zip \
        gd \
        gettext \
        opcache \
    # Install extensions for PHP 7.x
    && pecl channel-update pecl.php.net \
    && pecl install apcu-4.0.11 \
    && printf "no --disable-memcached-sasl\n" | pecl install memcached-2.2.0 \
    && echo extension=memcached.so > /usr/local/etc/php/conf.d/memcached.ini \
    && pecl install redis-4.3.0 \
     && pecl install xdebug-2.5.5 \
    && echo "zend_extension=xdebug.so" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo extension=apcu.so > /usr/local/etc/php/conf.d/apcu.ini \
    && echo extension=redis.so > /usr/local/etc/php/conf.d/redis.ini \
      # install ioncube
    && wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O /tmp/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xzf /tmp/ioncube_loaders_lin_x86-64.tar.gz -C /tmp \
    && cp /tmp/ioncube/ioncube_loader_lin_5.6.so  /usr/local/lib/php/extensions/no-debug-non-zts-20131226 \
    && echo "zend_extension=ioncube_loader_lin_5.6.so" > /usr/local/etc/php/conf.d/00_ioncube.ini \
    && rm -rf /tmp/ioncube* \
    # Uninstall dev and header packages
    && apt-get purge -y -f --force-yes \
        libc-client-dev \
        libkrb5-dev \
        libbz2-dev \
        libicu-dev \
        libldap2-dev \
        libldb-dev \
        libmcrypt-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        libpng-dev \
        libpq-dev \
        libzip-dev \
    && docker-image-cleanup
