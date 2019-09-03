FROM debian:stretch-slim

COPY files/usr/local/bin /usr/local/bin

#
# Adds interactive user snm
#
RUN useradd -m -s /bin/bash ssh && passwd -l ssh

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