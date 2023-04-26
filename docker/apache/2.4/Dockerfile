FROM httpd:2.4

LABEL de.sandstein.dde="apache"

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

RUN cd /tmp && \
    git clone https://github.com/devilbox/cert-gen.git && \
    cd cert-gen && \
    make install && \
    cd .. && \
    rm -rf cert-gen
