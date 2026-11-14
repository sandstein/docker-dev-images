# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Customized Docker images (published as `sandstein/<name>` on Docker Hub) for the
[Docker Development Environment (dde)](https://github.com/sandstein/docker-dev-environment).
Each image wraps an official upstream image (mostly Debian variants), adds debugging tools (vim, procps, net-tools,
dnsutils, git, …) and ships helper scripts so dde projects can remap the default user's UID/GID to the developer's own.
There is no application code and no test suite; "building" means building and tagging Docker images.

## Commands

All scripts must be run from the repository root (they use `docker compose` with the root `docker-compose.yml`).

```shell
bin/build.sh <container>            # build + tag all versions of one image family
                                    # (ssh, selenium-side-runner, apache, mariadb, mysql, elasticsearch, node, python)
bin/build.sh php <cli|fpm> <ver>    # build + tag one PHP image, e.g. bin/build.sh php cli 8.4
NAMESPACE=test bin/build.sh mysql   # tag as test/* instead of sandstein/* (keeps local sandstein images untouched)
bin/push.sh <name>                  # docker login + push all local tags of sandstein/<name> (needs Docker Hub access)
bin/cleanup.sh <label>              # prune images labelled de.sandstein.dde=<label>
docker compose build php-cli-8.5    # build a single service without tagging (quick check of one Dockerfile)
docker compose run --rm php-cli-8.5 php -m   # inspect a built image
```

## Architecture

- **`docker/<family>/<version>/Dockerfile`** – one Dockerfile per image version. The build context is always the repo
  root, so Dockerfiles reference shared files as `files/...`.
- **`docker-compose.yml`** – one service per image version (`<family>-<version>`, e.g. `php-fpm-8.4`, `mariadb-11.8`).
  It is used only for building/running images in `bin/build.sh`, not as a dev stack. The service name, the
  `dockerfile:` path and the `FROM` line must agree; they used to be crossed (e.g. `node-12` built node 16), which the
  hardcoded or unchecked tags hid. `build.sh` now checks the PHP and node versions against the requested ones.
- **`files/usr/local/bin/`** – helper scripts copied into every image (`COPY files/usr/local/bin /usr/local/bin`):
  - `apt-update` / `apt-install` / `docker-image-cleanup` – the standard pattern for installing packages in a layer
    (`apt-update && apt-install … && docker-image-cleanup`); keep using it so layers stay small.
  - `modify-user-ids <user> <uid> <gid>` – used by downstream dde Dockerfiles to remap the default user
    (`www-data` for php-fpm/apache, `phpcli` (UID 1000) for php-cli, `mysql`, `elasticsearch`, …).
  - `generate-locales`, `disable-php-modules`, `modify-elasticsearch-entrypoint`.
- **PHP images** install extensions via [mlocati/docker-php-extension-installer](https://github.com/mlocati/docker-php-extension-installer)
  (`install-php-extensions …`). Adding a PHP module usually means adding it to that list in the cli and fpm Dockerfiles
  for every relevant version. php-cli images additionally include nodejs/npm, git-flow and mariadb-client and create the
  `phpcli` user.
- Every image sets `LABEL de.sandstein.dde="<family>"`; `bin/cleanup.sh` relies on it.

## Tagging (bin/build.sh)

- `build.sh` runs with `set -euo pipefail` and a fixed `COMPOSE_PROJECT_NAME=sandstein-dev-images`; compose names the
  built images `sandstein-dev-images-<service>`, which are retagged to `${NAMESPACE:-sandstein}/<family>:<tag>`.
- Patch-level tags are discovered by running the built image without a tty (`docker compose run --rm -T`, e.g.
  `php -r 'echo PHP_VERSION;'`, `mariadbd`/`mysqld --version`, `httpd -v`). Elasticsearch tags are hardcoded.
- The `latest` tag is assigned explicitly in `build.sh` to the newest version of each family; for PHP only the image
  named in `PHP_LATEST` gets `sandstein/php:latest`. PHP images are tagged `sandstein/php:<type>-<minor>` and
  `sandstein/php:<type>-<patch>`.
- `install-php-extensions` is pinned to a release in every PHP Dockerfile; update all of them together.
- php-cli images must not declare `VOLUME` for the `phpcli` home (it creates root-owned anonymous volumes; dde
  bind-mounts `~/.config` and `~/.ssh`).

## Adding a new version

Touch all of these, they are not generated from each other:
1. `docker/<family>/<version>/Dockerfile`
2. a service in `docker-compose.yml`
3. the version loop and tag lines in `bin/build.sh` (move `latest` if it becomes the newest)
4. a job in `.gitlab-ci.yml` (PHP: one `build-php-<type>-<version>` job per type/version)
5. the version list in `README.md`

## CI

`.gitlab-ci.yml` runs on Sandstein's GitLab (runner tag `devimages`). Jobs are triggered by pipeline variables:
`BUILD_TARGET=<target>` (e.g. `mariadb`, `php-cli-8.4`) builds one job, `BUILD_ALL=true` builds everything. Each job
runs build → push → cleanup.

### GitHub Actions (multi-arch, trial)

`.github/workflows/build.yml` on the public mirror `github` (git@github.com:sandstein/docker-dev-images.git, default
branch `master`) builds the maintained targets natively on amd64 and arm64 runners via `bin/build.sh`. Branch pushes
and PRs only build; the weekly schedule and manual runs with `publish` push per-arch staging images to GHCR and merge
them into `sandstein/<repo>:<tag>` on Docker Hub (secrets `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`). The target list
lives in the workflow's `targets` job; keep it in sync with `build.sh`.
