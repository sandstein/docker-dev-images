# sandstein - dev images

## Introduction
This project provides customized Docker images to use with 
[Docker Development Environment](https://github.com/sandstein/docker-dev-environment). They are in general based on the 
official Docker images, preferably their debian variant with the addition of some development tools as vi with syntax highlighting 
and others to be used to check things inside the containers (see the respective Docker files for more information).

Also, there is a script added to change the user ID and group ID of the default user, so when running the containers in your 
dev environment you can change the user ID and group ID to your private one, so your working directory will not get polluted by
files belonging to other users.

## Image catalog

All maintained versions are listed in [`docker-bake.hcl`](docker-bake.hcl), the only place where versions are
defined. Each image family has one Dockerfile in `docker/<family>/Dockerfile` that gets the version as build
argument. Show all targets with their tags:
```shell
$ docker buildx bake --print
```
Targets are named after family and version with `-` instead of `.`, e.g. `php-cli-8-4`, `php-fpm-8-4-prod`,
`php-deploy-8-4`, `mariadb-11-8`. Every matrix (e.g. `php`, `node`) is also a group.

### Adding a version
Add the version to its list in `docker-bake.hcl`, e.g. `"8.6" = { all = "", cli = "" }` to `PHP` or `"12.0"` to
`MARIADB`. The last entry of a list gets the `latest` tag (for PHP: `PHP_LATEST`). Then mention the version below.
CI picks up new targets from the catalog by itself.

Removing a version from the catalog freezes it: its images stay on Docker Hub but are not rebuilt.

## Scripts

Run the scripts from the repository root.

### build.sh
Builds catalog targets or groups for the local platform, adds the patch-level tags and checks that every image
contains the version the catalog asks for:
```shell
$ bin/build.sh                       # all maintained images
$ bin/build.sh php                   # a group
$ bin/build.sh php-cli-8-4 node-24   # single targets
```
e.g. `php-cli-8-4` is tagged `sandstein/php:cli-8.4` and `sandstein/php:cli-8.4.<patch>`.

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
`.github/workflows/build.yml` builds all catalog targets natively for `linux/amd64` and `linux/arm64`.
Pushing a tag, the weekly schedule (Sundays 16:12 UTC) and manual runs with *publish* checked
push multi-arch images to Docker Hub; branch pushes start nothing (repository secrets `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`). A manual run
can also build a single target or group (e.g. `mariadb` or `php-cli-8-4`).

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
Not built anymore. The images for versions 5.6, 6.4, 6.8, 7.1, 7.3, 7.6, 7.10, 7.16, 7.17 and 8.6 stay on Docker Hub
(sources: tag `26.11.13`). Use

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

Versions 11.4 and 11.8 are built; the images for 10.2 to 10.7 stay on Docker Hub but are not rebuilt. Use

```dockerfile
ARG USER_ID=999
ARG GROUP_ID=999
RUN modify-user-ids mysql ${USER_ID} ${GROUP_ID}
```
for user customisation.

### mysql

Version 8.4 is built; the images for 5.7 and 8.0 stay on Docker Hub but are not rebuilt. Use

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
PHP 8.2 to 8.5 as fpm and cli, each in two variants:

- `sandstein/php:<type>-<version>` (e.g. `fpm-8.4`): development image with xdebug and xhprof, the cli images also
  with node and npm.
- `sandstein/php:<type>-<version>-prod` (e.g. `fpm-8.4-prod`): without xdebug, xhprof and node, with PHP's
  `php.ini-production`.

The images for 7.3 to 8.1 stay on Docker Hub but are not rebuilt. Use

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
for the cli containers. `sandstein/php:latest` is the newest cli development image.

#### php-deploy
`sandstein/php-deploy:<version>` (e.g. `8.4`, also `8.4.<patch>`) is the image for deployment jobs in GitLab CI. It
is built on `cli-<version>-prod` and adds:

- the user `gitlab-runner` (UID/GID 999) instead of `phpcli`, home `/home/gitlab-runner`
- composer and [Deployer](https://deployer.org/) (`dep`, major version pinned with `DEPLOYER_VERSION` in
  `docker/php/Dockerfile`) in `~/bin`
- Debian's nodejs/npm, plus nvm with the current node LTS for shells that source `~/.nvm/nvm.sh`
- `memory_limit = -1` and `date.timezone = Europe/Berlin` on top of `php.ini-production`

It used to be built in the separate `docker-deploy-images` repository; the 8.1 image stays on Docker Hub but is not
rebuilt.

#### php modules
The containers try to include all available modules. The common list is in `docker/php/Dockerfile`, version
specific additions are in `docker-bake.hcl`. When using the containers, you can disable
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
`elasticsearch`, `percona` (5.7, 8.0) and `solr` (7.7, 8.9) are not built anymore. Their last images stay available on Docker Hub.
