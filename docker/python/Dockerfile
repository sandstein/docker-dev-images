ARG VERSION=3.10
FROM python:${VERSION}

LABEL de.sandstein.dde="python"

COPY files/usr/local/bin /usr/local/bin

RUN install-dev-tools

COPY files/etc/motd/python /etc/motd

RUN python -m pip install --upgrade pip \
    && pip install virtualenv

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN useradd --create-home --uid ${USER_ID} --shell /bin/bash --user-group python \
    && echo 'cat /etc/motd' >> /home/python/.bashrc
