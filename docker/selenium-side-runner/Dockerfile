FROM node:lts-bullseye-slim

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
    # Install packages and common tools
    && apt-install \
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
    && /usr/local/bin/generate-locales \
    && docker-image-cleanup

RUN npm install -g selenium-side-runner
