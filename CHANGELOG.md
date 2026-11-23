# Changelog

All notable changes to the images and the build. Versions are the release tags (`YY.MM.DD[.n]`), published to
[Docker Hub](https://hub.docker.com/u/sandstein) by the GitHub Actions build.
German version: [CHANGELOG.de.md](CHANGELOG.de.md).

## 26.11.23

### Added
- PHP 8.6 (`php:cli-8.6`, `php:fpm-8.6`, the `-prod` variants and `php-deploy:8.6`). The extension installer does not
  support all extensions on 8.6 yet, so these are left out for now: amqp, apcu, gnupg, grpc, imagick, imap, lzf,
  memcached, oauth, redis, xlswriter, xmlrpc, solr, sourceguardian and xdebug. `php:latest` stays on 8.5.
- `skip` per PHP version in `docker-bake.hcl` and the helper `install-php-extensions-except`, to leave out extensions
  a version cannot install yet.
- `sandstein/php-deploy:<version>` for 8.2 to 8.6, formerly built in the separate `docker-deploy-images`
  repository. It is now based on `php:cli-<version>-prod` and built weekly and multi-arch with the other images:
  user `gitlab-runner` (UID/GID 999), composer, Deployer, Debian nodejs/npm plus nvm with the node LTS,
  `memory_limit = -1` and `date.timezone = Europe/Berlin`.

### Changed
- php-deploy: the images use `php.ini-production` with the two settings above, instead of an almost empty `php.ini`.
  `display_errors` is now off.
- php-deploy: Deployer is pinned per PHP version: `^8`, and `^7` for PHP 8.2 (Deployer 8 needs PHP 8.3).
- GitHub Actions use their Node 24 versions.

## 26.11.14.3

### Fixed
- Pushing a tag publishes the images again.

## 26.11.14.2

### Changed
- The build only runs for tags, the weekly schedule and manual runs, not for branch pushes.

## 26.11.14.1

### Fixed
- Publishing: retries the push to the GHCR staging registry, which failed when amd64 and arm64 created a new package at
  the same time.

## 26.11.14

### Added
- Multi-arch images (amd64 and arm64), built natively on GitHub Actions and merged on Docker Hub, only if both
  architectures produce the same tags. A weekly build (Sundays 16:12 UTC) keeps the images up to date.
- `sandstein/php:<type>-<version>-prod` tags without xdebug, xhprof and node, with `php.ini-production`.

### Changed
- One catalog (`docker-bake.hcl`) lists all versions, with one Dockerfile per image family. `bin/build.sh` builds with
  `docker buildx bake`, adds the patch tags and checks that each image contains the version in its name.
- `install-dev-tools` installs the common tool set in every image.

### Removed
- GitLab CI and its schedules; GitHub Actions is the only build.
- The sources of the frozen EOL versions (still available at tag `26.11.13`).

## 26.11.13

### Fixed
- `php:fpm-8.5` was built from PHP 8.4.
- Wrong Dockerfiles for elasticsearch 7.6/7.17/8.6 and node 12/14; elasticsearch 8.6 is really 8.6.2.
- `php:fpm-8.4` failed to build because gmagick and imagick were installed together; PHP 8.2 to 8.5 now use imagick.
- `modify-user-ids` handles UIDs that are already in use and existing groups without renumbering them.
- php-cli no longer declares a `VOLUME` for the home directory (it created root-owned `~/.ssh` and `~/.config`).

### Changed
- node 22, 24 and 26 (LTS) on Debian trixie replace node 11 to 18. ssh and selenium-side-runner use Debian trixie.
- PHP images set `LANG=C.UTF-8`; the PHP extension installer is pinned.
- `bin/build.sh` stops on errors and supports `NAMESPACE=test` for local builds.

### Removed
- EOL versions are frozen, their images stay on Docker Hub: PHP 7.3 to 8.1, MariaDB 10.x, MySQL 5.7 and 8.0,
  elasticsearch, percona and solr.

## Before 26.11.13

See the git history. Older tags use a different naming (`23.03.25`, `17486-node-for-all`, …).
