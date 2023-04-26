FROM debian:buster-slim

LABEL de.sandstein.dde="percona"

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

ENV PERCONA_SETUP ps57
ENV MYSQL_MAJOR 5.7

RUN wget https://repo.percona.com/apt/percona-release_latest.buster_all.deb
RUN dpkg -i percona-release_latest.buster_all.deb ; \
  apt-get update; \
  percona-release setup ${PERCONA_SETUP}; \
  apt-install percona-server-server-"$MYSQL_MAJOR"; \
  rm percona-release_latest.buster_all.deb
RUN rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
    	&& chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
    	&& chmod 777 /var/run/mysqld

VOLUME ["/var/lib/mysql", "/var/log/mysql"]

RUN sed -i s"/^log-error/# log-error/g" /etc/mysql/percona-server.conf.d/mysqld.cnf \
    && mkdir /docker-entrypoint-initdb.d
COPY files/entrypoints/percona-entry-"$MYSQL_MAJOR".sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

USER mysql
EXPOSE 3306
CMD ["mysqld"]
