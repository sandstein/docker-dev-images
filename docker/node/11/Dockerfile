FROM node:11-stretch

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
        python \
    && /usr/local/bin/generate-locales \
    && docker-image-cleanup

RUN npm install -g node-build-tools