ARG VERSION=26
FROM node:${VERSION}-trixie

LABEL de.sandstein.dde="node"

COPY files/usr/local/bin /usr/local/bin

RUN install-dev-tools build-essential

RUN npm install -g node-build-tools
