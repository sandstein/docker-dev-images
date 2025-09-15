FROM mysql:8.4

LABEL de.sandstein.dde="mysql"

COPY files/usr/local/bin /usr/local/bin

RUN set -eux; \
      microdnf install -y \
        wget \
        curl \
        vim \
        net-tools \
        tzdata \
        zip \
        unzip \
        bzip2 \
        dnsutils \
        rsync \
        git \
        patch
