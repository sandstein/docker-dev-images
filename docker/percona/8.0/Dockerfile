FROM debian:buster-slim

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r mysql && useradd -r -g mysql mysql

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
        patch \
        lsb-release \
        gnupg2 \
        dirmngr \
        pwgen \
        openssl \
        perl \
        xz-utils \
    && /usr/local/bin/generate-locales \
    && docker-image-cleanup

ENV PERCONA_SETUP ps80
ENV MYSQL_MAJOR 8.0

RUN wget https://repo.percona.com/apt/percona-release_latest.buster_all.deb
RUN dpkg -i percona-release_latest.buster_all.deb ; \
  apt-get update; \
  percona-release setup ${PERCONA_SETUP}; \
  apt-install percona-server-server; \
  rm percona-release_latest.buster_all.deb
RUN rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
    	&& chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
    	&& chmod 777 /var/run/mysqld

VOLUME ["/var/lib/mysql", "/var/log/mysql"]

RUN sed -i s"/^log-error/# log-error/g" /etc/mysql/mysql.conf.d/mysqld.cnf \
    && mkdir /docker-entrypoint-initdb.d
COPY files/entrypoints/percona-entry-"$MYSQL_MAJOR".sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

USER mysql
EXPOSE 3306
CMD ["mysqld"]
