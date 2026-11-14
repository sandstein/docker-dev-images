# the image is tagged with the selenium-side-runner version; NODE_VERSION only picks the base image
ARG NODE_VERSION=24
FROM node:${NODE_VERSION}-trixie-slim

LABEL de.sandstein.dde="selenium-side-runner"

COPY files/usr/local/bin /usr/local/bin

RUN install-dev-tools

RUN npm install -g selenium-side-runner
