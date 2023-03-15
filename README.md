# sandstein - dev images

## Introduction
This project provides customized Docker images to use with 
[Docker Development Environment](https://github.com/sandstein/docker-dev-environment). They are in general based on the 
official Docker images, preferably their debian variant with the addition of some development tools as vi with syntax highlighting 
and others to be used to check things inside the containers (see the respective Docker files for more information).

Also, there is a script added to change the user ID and group ID of the default user, so when running the containers in your 
dev environment you can change the user ID and group ID to your private one, so your working directory will not get polluted by
files belonging to other users.

## Scripts

The project contains two scripts, one for building the different containers and one for pushing them to docker hub.
### build.sh
To locally build one or all containers of a specific variety use
```shell
$ bin/build.sh <container>
```
where the container is one of the container names written down below. This builds and tags
all variants of the container type except for php, where you have to use
```shell
$ bin/build.sh php <type> <version>
```
which will build the fpm or cli type of the latest minor version of version, eg.:
```shell
$ bin/build.sh php cli 8.2
```
will (at the time of writing) build and tag a php cli container with v8.2.3.

### push.sh
This command is used to push the locally tagged version to docker hub. Use:

```shell
$ bin/build.sh <container>
```
Beware: this pushes to the [sandstein repositories](https://hub.docker.com/orgs/sandstein/repositories), 
which you probably do not have access for. so if you want to use your own repository you should change
the file here.

### .gitlab-ci.yml
To automatize the push of the latest versions there is a Gitlab-CI configuration which regularly builds the
docker containers and pushes them to dockerhub.
For now sandstein's own gitlab instance is used to do so, we might change this to some GitHub Actions in the future.

## Container

The containers prepared here are the following (in alphabetical order):

### apache
An apache webserver container. Only version 2.4 is built. Use

```dockerfile
ARG USER_ID=33
ARG GROUP_ID=33
RUN modify-user-ids www-data ${USER_ID} ${GROUP_ID}
```
in your Dockerfile to run it as your current user.

### elasticsearch
Versions 5.6, 6.4, 6.8, 7.1, 7.3, 7.6, 7.10, 7.16, 7.17 and 8.6 are prepared. Use

```dockerfile
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN modify-user-ids elasticsearch ${USER_ID} ${GROUP_ID} \
    && modify-elasticsearch-entrypoint

RUN bin/elasticsearch-plugin install analysis-phonetic \
    && bin/elasticsearch-plugin install analysis-icu
```
in your Dockerfile to run it as your current user and to install additional plugins.

## mariadb

Versions 10.2 to 10.7 are prepared. Use

```dockerfile
ARG USER_ID=999
ARG GROUP_ID=999
RUN modify-ids mysql ${USER_ID} ${GROUP_ID}
```
for user customisation.

## mysql

Versions 5.6, 5.7 and 8.0 are prepared. Use

```dockerfile
ARG USER_ID=999
ARG GROUP_ID=999
RUN modify-ids mysql ${USER_ID} ${GROUP_ID}
```
for user customisation.

## node
NodeJS container for versions 11, 12, 14, 16 and 18 are provided. They include the node-build-tools. No user customisation
available, since it was not needed.

## percona

Versions 5.7 and 8.0 are provided. Use

```dockerfile
ARG USER_ID=999
ARG GROUP_ID=999
RUN modify-ids mysql ${USER_ID} ${GROUP_ID}
```
for user customisation.

### php
A collection of all mayor PHP versions (from 7.3 to 8.2) as fpm and cli. Use

```dockerfile
ARG USER_ID=33
ARG GROUP_ID=33
RUN modify-user-ids www-data ${USER_ID} ${GROUP_ID}
```

for the fpm containers and

```dockerfile
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN modify-user-ids phpcli ${USER_ID} ${GROUP_ID}
```
for the cli containers

#### php modules
The containers try to include all available modules. When using the containers, you can disable
the modules in your config. If you miss something just add a PR, most of the modules are built with 
[Docker PHP-Extension Installer](https://github.com/mlocati/docker-php-extension-installer), so if a module can be
installed it is really easy to add it.

### python
A python image (v3.10) is provided. It includes a user which can be mapped to your needs with
```dockerfile
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN modify-user-ids phpcli ${USER_ID} ${GROUP_ID} 
``` 

### selenium-side-runner
Based on NodeJS v14 this image can be used to run selenium tests

### solr
Provides versions 7.6 and 8.9 of the search platform. Use

```dockerfile
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN modify-user-ids solr ${USER_ID} ${GROUP_ID} \
    mkdir /opt/solr/lib \
    chown -R solr.solr /opt/solr \
    chown -R solr.solr /opt/docker-solr

USER solr
```
to run solar as your local user.

### ssh
A slim debian with an additional user "ssh", mainly used for port forwarding. To use in your own context
add this to your Dockerfile

```dockerfile
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN modify-ids ssh ${USER_ID} ${GROUP_ID}
```

See especially the [docker-compose.yml](https://github.com/sandstein/docker-dev-environment/blob/7355445575f2ae650941bbf0bdb4f1ad699303e6/docker-compose.yml#L610)
in [Docker Development Environment](https://github.com/sandstein/docker-dev-environment) for more details.


