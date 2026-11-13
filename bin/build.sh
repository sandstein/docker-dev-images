#!/bin/bash
#
# Builds one image family with docker compose and tags it as ${NAMESPACE:-sandstein}/<family>:<tag>.
#
#   bin/build.sh <family>                 e.g. bin/build.sh mariadb
#   bin/build.sh php <cli|fpm> <version>  e.g. bin/build.sh php cli 8.4
#
# Must be run from the repository root. Fails (and tags nothing more) as soon
# as a build fails or a version cannot be determined.

set -o errexit
set -o nounset
set -o pipefail

#BUILD_ARGS="--force-rm --pull"
BUILD_ARGS=()

# target namespace; set NAMESPACE=test to build and tag without touching sandstein/* images
NAMESPACE=${NAMESPACE:-sandstein}

# fixed project name, so the image names do not depend on the checkout directory
export COMPOSE_PROJECT_NAME=sandstein-dev-images

# the PHP image that also gets sandstein/php:latest
PHP_LATEST="cli-8.5"

usage() {
  cat >&2 <<EOF
usage: $0 <family>
       $0 php <cli|fpm> <version>

families: ssh selenium-side-runner apache mariadb mysql elasticsearch node python php
EOF
  exit 2
}

build() {
  docker compose build "${BUILD_ARGS[@]}" "$1"
}

# run <service> <command...>: runs a command in the built image without a tty
run() {
  docker compose run --rm -T "$@"
}

# tag <service> <repository> <tag...>
tag() {
  local service=$1 repository=$2
  shift 2
  for tag in "$@"; do
    docker tag "${COMPOSE_PROJECT_NAME}-${service}:latest" "${NAMESPACE}/${repository}:${tag}"
  done
}

# version <output>: extracts the first x.y[.z] version number, fails without one
version() {
  local found
  found=$(grep --only-matching --perl-regexp '\d+\.\d+(\.\d+)?' <<< "$1" | head -n1)
  if [[ -z "${found}" ]]; then
    echo "could not determine a version from: $1" >&2
    return 1
  fi
  echo "${found}"
}

[[ $# -ge 1 ]] || usage

case $1 in

ssh)
  # ssh (https://hub.docker.com/_/debian)
  build ssh
  tag ssh ssh 13 trixie latest
  ;;

selenium-side-runner)
  # selenium-side-runner (https://hub.docker.com/_/node)
  build selenium-side-runner
  v=$(version "$(run selenium-side-runner selenium-side-runner --version)")
  tag selenium-side-runner selenium-side-runner "${v}" 24 latest
  ;;

apache)
  # apache (https://hub.docker.com/_/httpd)
  build apache-2.4
  v=$(version "$(run apache-2.4 httpd -v | grep '^Server version')")
  tag apache-2.4 apache 2.4 "${v}" latest
  ;;

mariadb)
  # mariadb (https://hub.docker.com/_/mariadb)
  # frozen (EOL, not rebuilt): 10.2 10.3 10.4 10.5 10.6 10.7
  for minor in 11.4 11.8; do
    build "mariadb-${minor}"
    v=$(version "$(run "mariadb-${minor}" mariadbd --version)")
    tags=("${minor}" "${v}")
    [[ ${minor} == 11.8 ]] && tags+=(latest)
    tag "mariadb-${minor}" mariadb "${tags[@]}"
  done
  ;;

mysql)
  # mysql (https://hub.docker.com/_/mysql)
  # frozen (EOL, not rebuilt): 5.7 8.0
  # shellcheck disable=SC2043 # one maintained version for now
  for minor in 8.4; do
    build "mysql-${minor}"
    v=$(version "$(run "mysql-${minor}" mysqld --version)")
    tags=("${minor}" "${v}")
    [[ ${minor} == 8.4 ]] && tags+=(latest)
    tag "mysql-${minor}" mysql "${tags[@]}"
  done
  ;;

php)
  # php (cli and fpm) (https://hub.docker.com/_/php/)
  [[ $# -eq 3 ]] || usage
  type=$2
  minor=$3
  [[ ${type} == cli || ${type} == fpm ]] || usage
  service="php-${type}-${minor}"
  build "${service}"
  v=$(version "$(run "${service}" php -r 'echo PHP_VERSION;')")
  if [[ ${v} != "${minor}".* ]]; then
    echo "${service} contains PHP ${v}, expected ${minor}.x" >&2
    exit 1
  fi
  tags=("${type}-${minor}" "${type}-${v}")
  [[ "${type}-${minor}" == "${PHP_LATEST}" ]] && tags+=(latest)
  tag "${service}" php "${tags[@]}"
  ;;

elasticsearch)
  # elasticsearch (https://www.docker.elastic.co/r/elasticsearch), versions are fixed;
  # all are frozen, CI builds them only with BUILD_TARGET=elasticsearch
  for minor in 5.6 6.4 6.8 7.1 7.3 7.6 7.10 7.16 7.17 8.6; do
    build "elasticsearch-${minor}"
  done
  tag elasticsearch-5.6 elasticsearch 5 5.6 5.6.16
  tag elasticsearch-6.4 elasticsearch 6.4 6.4.3
  tag elasticsearch-6.8 elasticsearch 6 6.8 6.8.23
  tag elasticsearch-7.1 elasticsearch 7.1 7.1.1
  tag elasticsearch-7.3 elasticsearch 7.3 7.3.2
  tag elasticsearch-7.6 elasticsearch 7.6 7.6.2
  tag elasticsearch-7.10 elasticsearch 7.10 7.10.1
  tag elasticsearch-7.16 elasticsearch 7.16 7.16.3
  tag elasticsearch-7.17 elasticsearch 7 7.17 7.17.8
  tag elasticsearch-8.6 elasticsearch 8 8.6 8.6.2 latest
  ;;

node)
  # node (https://hub.docker.com/_/node)
  for major in 22 24 26; do
    build "node-${major}"
    v=$(version "$(run "node-${major}" node -v)")
    if [[ ${v} != "${major}".* ]]; then
      echo "node-${major} contains node ${v}" >&2
      exit 1
    fi
    tags=("${major}" "${v}")
    [[ ${major} == 26 ]] && tags+=(latest)
    tag "node-${major}" node "${tags[@]}"
  done
  ;;

python)
  # python (https://hub.docker.com/_/python)
  build python-3.10
  v=$(version "$(run python-3.10 python -V)")
  tag python-3.10 python 3.10 "${v}" latest
  ;;

*)
  usage
  ;;
esac
