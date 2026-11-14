ARG VERSION=11.8
FROM mariadb:${VERSION}

LABEL de.sandstein.dde="mariadb"

COPY files/usr/local/bin /usr/local/bin

RUN install-dev-tools
