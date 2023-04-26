FROM debian:bullseye-slim

LABEL de.sandstein.dde="ssh"

COPY files/usr/local/bin /usr/local/bin

COPY files/commands/ssh-cmd.sh  /usr/local/bin/
#
# Adds interactive user snm
#
RUN useradd -m -s /bin/bash ssh && passwd -l ssh

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
    && /usr/local/bin/generate-locales \
    && docker-image-cleanup

CMD ["ssh-cmd.sh"]
