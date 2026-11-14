# VERSION is the Debian codename
ARG VERSION=trixie
FROM debian:${VERSION}-slim

LABEL de.sandstein.dde="ssh"

COPY files/usr/local/bin /usr/local/bin

COPY files/commands/ssh-cmd.sh /usr/local/bin/

# interactive user without password
RUN useradd -m -s /bin/bash ssh && passwd -l ssh

RUN install-dev-tools autossh

CMD ["ssh-cmd.sh"]
