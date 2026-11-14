ARG VERSION=2.4
FROM httpd:${VERSION}

LABEL de.sandstein.dde="apache"

COPY files/usr/local/bin /usr/local/bin

RUN install-dev-tools build-essential

RUN cd /tmp \
    && git clone https://github.com/devilbox/cert-gen.git \
    && cd cert-gen \
    && make install \
    && cd .. \
    && rm -rf cert-gen
