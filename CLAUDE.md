# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Customized Docker images (published as `sandstein/<name>` on Docker Hub) for the
[Docker Development Environment (dde)](https://github.com/sandstein/docker-dev-environment).
Each image wraps an official upstream image (mostly Debian variants), adds debugging tools (vim, procps, net-tools,
dnsutils, git, …) and ships helper scripts so dde projects can remap the default user's UID/GID to the developer's own.
There is no application code and no test suite; "building" means building and tagging Docker images.

## Commands

All scripts must be run from the repository root.

```shell
docker buildx bake --print [target|group]   # show the catalog: targets, args, tags
bin/build.sh                                # build + tag everything maintained (bake group "default")
bin/build.sh php mariadb-11-8               # groups and/or targets (names use - for ., e.g. php-fpm-8-4-prod)
NAMESPACE=test bin/build.sh mysql           # tag as test/* instead of sandstein/* (keeps local sandstein images untouched)
TAGS_FILE=tags.txt bin/build.sh node        # also write every resulting image reference to a file (used by CI)
bin/push.sh <name>                          # docker login + push all local tags of sandstein/<name> (needs Docker Hub access)
bin/cleanup.sh <label>                      # prune images labelled de.sandstein.dde=<label>
docker run --rm --entrypoint '' test/php:cli-8.5 php -m   # inspect a built image
```

## Architecture

- **`docker-bake.hcl`** – the catalog and the only place where versions live. Variables `PHP` (version => extra
  extensions `{all, cli}`), `PHP_LATEST`, `MARIADB`, `MYSQL`, `NODE`, `PYTHON`, `APACHE`; matrix targets expand to
  `<family>-<version>` (dots become dashes), each matrix is also a group, `default` builds everything. The first tag of
  a target is its minor tag; the last list entry gets `latest`.
- **`docker/<family>/Dockerfile`** – one Dockerfile per family, the version comes in as `ARG VERSION` (ssh: Debian
  codename; selenium-side-runner: `NODE_VERSION`, its tag is the selenium-side-runner version). The build context is
  the repo root, so Dockerfiles reference shared files as `files/...`.
- **`docker/php/Dockerfile`** – stages `common` (tools + common extensions + `EXTENSIONS`), `cli` (git-flow,
  ghostscript, mariadb-client, solr, sourceguardian, `CLI_EXTENSIONS`, `phpcli` user), and the bake targets
  `cli-dev`/`fpm-dev` (xdebug, xhprof; cli also nodejs/npm) and `cli-prod`/`fpm-prod` (`php.ini-production`, tagged
  `<type>-<version>-prod`). `install-php-extensions` is pinned once via `ARG INSTALLER_VERSION`.
- **`files/usr/local/bin/`** – helper scripts copied into every image (`COPY files/usr/local/bin /usr/local/bin`):
  - `install-dev-tools [pkg …]` – the standard tool list for every image (apt or microdnf), plus extra packages, with
    cleanup. Change the common tool set there, not in the Dockerfiles.
  - `apt-update` / `apt-install` / `docker-image-cleanup` – the pattern for installing other packages in a layer.
  - `modify-user-ids <user> <uid> <gid>` – used by downstream dde Dockerfiles to remap the default user
    (`www-data` for php-fpm/apache, `phpcli` (UID 1000) for php-cli, `mysql`, `node`, `python`, `ssh`).
  - `generate-locales`, `disable-php-modules`.
- Every image sets `LABEL de.sandstein.dde="<family>"`; `bin/cleanup.sh` relies on it.
- Frozen (EOL) versions are not in the repo anymore (PHP 7.3–8.1, MariaDB 10.x, MySQL 5.7/8.0, Elasticsearch, percona,
  solr); their images stay on Docker Hub, their sources are at tag `26.11.13`.

## Tagging (bin/build.sh)

- `build.sh` runs `docker buildx bake --load` with the catalog's tags, then runs each image without its entrypoint to
  find the real version (`php -r 'echo PHP_VERSION;'`, `mariadbd`/`mysqld --version`, `httpd -v`, `node -v`, …).
- The real version must start with the catalog's `VERSION` (crossed versions used to hide behind hardcoded tags); the
  patch tag replaces it in the minor tag (`cli-8.4-prod` → `cli-8.4.15-prod`). Targets without `VERSION`
  (selenium-side-runner) get the detected version as an extra tag; ssh has none.
- Downstream dde uses the minor tags (`php:fpm-8.4`, `mariadb:11.8`, `node:24`, …); they are the contract.
- php-cli images must not declare `VOLUME` for the `phpcli` home (it creates root-owned anonymous volumes; dde
  bind-mounts `~/.config` and `~/.ssh`).

## Adding a new version

Add it to its list in `docker-bake.hcl` (move `PHP_LATEST` for a new PHP), then update the version list in
`README.md`. CI reads its targets from the catalog.

## CI

`.github/workflows/build.yml` runs on the public GitHub mirror (remote `github`,
git@github.com:sandstein/docker-dev-images.git). It reads the targets from `docker buildx bake --print`, groups each
PHP target with its `-prod` variant into one job and runs `bin/build.sh` natively on amd64 and arm64 runners. Branch
pushes and PRs only build; the weekly schedule (Sundays 16:12 UTC, default branch only) and manual runs with `publish`
push per-arch staging images to GHCR and merge them into multi-arch tags on Docker Hub (secrets `DOCKERHUB_USERNAME`,
`DOCKERHUB_TOKEN`), only if both arches yield the same tag list. A manual run can build one target or group. GitLab CI
and its schedules were removed (2026-11-14).
