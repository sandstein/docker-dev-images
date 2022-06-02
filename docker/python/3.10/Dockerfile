FROM python:3.10

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
    && /usr/local/bin/generate-locales \
    && docker-image-cleanup

COPY files/etc/motd/python /etc/motd

RUN python -m pip install --upgrade pip &&  \
    pip install virtualenv

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN useradd --create-home --uid ${USER_ID} --shell /bin/bash --user-group python && \
    echo 'cat /etc/motd' >> /home/python/.bashrc

