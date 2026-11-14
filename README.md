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

The project contains three scripts: one for building the different containers, one for pushing them to docker hub and
one for cleaning up afterwards. Run them from the repository root.

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
which will build the fpm or cli type of the latest patch version of version, eg.:
```shell
$ bin/build.sh php cli 8.4
```
builds and tags `sandstein/php:cli-8.4` and `sandstein/php:cli-8.4.<patch>`.

The script stops at the first failing build or version check. To try a build without overwriting your local
`sandstein/*` images, set another namespace:
```shell
$ NAMESPACE=test bin/build.sh mariadb
```

### push.sh
This command is used to push the locally tagged version to docker hub. Use:

```shell
$ bin/push.sh <container>
```
Beware: this pushes to the [sandstein repositories](https://hub.docker.com/orgs/sandstein/repositories), 
which you probably do not have access for. so if you want to use your own repository you should change
the file here.

### cleanup.sh
Removes the local images of a container type (by their `de.sandstein.dde` label):
```shell
$ bin/cleanup.sh <container>
```

### GitHub Actions
`.github/workflows/build.yml` builds the maintained images natively for `linux/amd64` and `linux/arm64`.
Pushes and pull requests only build. The weekly schedule (Sundays 16:12 UTC) and manual runs with *publish* checked
push multi-arch images to Docker Hub (repository secrets `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`). A manual run
can also build a single target (e.g. `mariadb` or `php-cli-8.4`).

## Changing user and group IDs

All images contain `modify-user-ids`:

```dockerfile
RUN modify-user-ids <user> <uid> <gid>
```

It changes the uid and the primary group of the user and keeps the files in the user's home directory owned by the
user. If the uid is already used by another user of the image, it is shared. If a group with the gid already exists
(e.g. gid 20 on macOS, which is `dialout` in Debian), the user joins that group.

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

Elasticsearch 8 runs as the `elasticsearch` user. The 8.6 image therefore stays `root`, so the lines above work
unchanged, and its entrypoint starts Elasticsearch as the (renumbered) `elasticsearch` user. For a local single node
without TLS set `discovery.type=single-node` and `xpack.security.enabled=false`.

Before November 2026 some tags contained other versions: `7.6` was 7.3.2, `7.17` was 7.16.3 and `8.6` was 7.17.8.

### mariadb

Versions 10.2 to 10.7, 11.4 and 11.8 are prepared. Use

```dockerfile
ARG USER_ID=999
ARG GROUP_ID=999
RUN modify-user-ids mysql ${USER_ID} ${GROUP_ID}
```
for user customisation.

### mysql

Versions 5.7, 8.0 and 8.4 are prepared. Use

```dockerfile
ARG USER_ID=999
ARG GROUP_ID=999
RUN modify-user-ids mysql ${USER_ID} ${GROUP_ID}
```
for user customisation.

### node
NodeJS containers for the LTS versions 22, 24 and 26 (Debian trixie) are provided; `latest` is 26. They include
the node-build-tools. Use

```dockerfile
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN modify-user-ids node ${USER_ID} ${GROUP_ID}
```
for user customisation. The old images for node 11 to 18 stay on Docker Hub but are not built anymore
(`node:12` and `node:14` contained node 16).

### php
A collection of all major PHP versions (from 7.3 to 8.5) as fpm and cli. Use

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
for the cli containers. `sandstein/php:latest` is the newest cli image.

#### php modules
The containers try to include all available modules. When using the containers, you can disable
the modules in your config, e.g. with `disable-php-modules xdebug,xhprof`. If you miss something just add a PR,
most of the modules are built with 
[Docker PHP-Extension Installer](https://github.com/mlocati/docker-php-extension-installer), so if a module can be
installed it is really easy to add it.

### python
A python image (v3.10) is provided. It includes a user which can be mapped to your needs with
```dockerfile
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN modify-user-ids python ${USER_ID} ${GROUP_ID} 
``` 

### selenium-side-runner
Based on NodeJS 24 (Debian trixie) this image can be used to run selenium tests. The old `14` tag is not built anymore.

### ssh
A slim debian (13, trixie) with an additional user "ssh", mainly used for port forwarding. To use in your own context
add this to your Dockerfile

```dockerfile
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN modify-user-ids ssh ${USER_ID} ${GROUP_ID}
```

See especially the [docker-compose.yml](https://github.com/sandstein/docker-dev-environment/blob/7355445575f2ae650941bbf0bdb4f1ad699303e6/docker-compose.yml#L610)
in [Docker Development Environment](https://github.com/sandstein/docker-dev-environment) for more details.

### No longer built
`percona` (5.7, 8.0) and `solr` (7.7, 8.9) are not built anymore. Their last images stay available on Docker Hub.
