FROM node:16-bullseye

LABEL de.sandstein.dde="node"

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
        build-essential \
    && /usr/local/bin/generate-locales \
    && docker-image-cleanup

RUN npm install -g node-build-tools