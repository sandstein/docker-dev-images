#!/bin/bash

BUILD_ARGS="--force-rm --pull --quiet"

tag() {
  for tag in $2
  do
    docker tag "dev-images_$1:latest" "sandstein/$1:$tag"
  done

}

tag_version() {
  for tag in $3
  do
    docker tag "dev-images_$1-$2:latest" "sandstein/$1:$tag"
  done
}

tag_php_version() {
  for tag in $4
  do
    docker tag "dev-images_$1-$2:latest" "sandstein/$1:$2-$tag"
  done
}



docker login

# ssh (https://hub.docker.com/_/debian)
docker-compose build ${BUILD_ARGS} ssh
tag "ssh" "11 bullseye latest"


# selenium-side-runner (https://hub.docker.com/_/node)
docker-compose build ${BUILD_ARGS} selenium-side-runner
tag selenium-side-runner "lts-bullsey-slim latest"

# apache (https://hub.docker.com/_/httpd)
docker-compose build ${BUILD_ARGS} apache-2.4
tag_version "apache" "2.4" "2.4 2.4.52 latest"

# mariadb (https://hub.docker.com/_/mariadb)
for version in 10.2 10.3 10.4 10.5 10.6 10.7
do
  docker-compose build ${BUILD_ARGS} "mariadb-$version"
done
tag_version "mariadb" "10.2" "10.2 10.2.41"
tag_version "mariadb" "10.3" "10.3 10.3.32"
tag_version "mariadb" "10.4" "10.4 10.4.22"
tag_version "mariadb" "10.5" "10.5 10.5.13"
tag_version "mariadb" "10.6" "10.6 10.6.5 latest"
tag_version "mariadb" "10.7" "10.7 10.7.1"

# mysql (https://hub.docker.com/_/mysql)
for version in 5.6 5.7 8.0
do
  docker-compose build ${BUILD_ARGS} "mysql-$version"
done
tag_version "mysql" "5.6" "5.6 5.6.51"
tag_version "mysql" "5.7" "5.7 5.36"
tag_version "mysql" "8.0" "8.0 8.0.27 latest"

# percona (https://hub.docker.com/r/percona/percona-server)
for version in 5.7 8.0
do
  docker-compose build ${BUILD_ARGS} "percona-$version"
done
tag_version "percona" "5.7" "5.7 5.7.36"
tag_version "percona" "8.0" "8.0 8.0.26 latest"

# php (cli and fpm) (https://hub.docker.com/_/php/)
for type in cli fpm
do
  for version in 7.3 7.4 8.0 8.1
  do
    docker-compose build ${BUILD_ARGS} php-$type-$version
  done
done

for type in cli fpm
do
  tag_php_version "php" "$type" "7.3" "7.3 7.3.29"
  tag_php_version "php ""$type" "7.4" "7.4 7.3.27"
  tag_php_version "php" "$type" "8.0" "8.0 8.0.14"
  tag_php_version "php" "$type" "8.1" "8.1 8.1.1"
done

