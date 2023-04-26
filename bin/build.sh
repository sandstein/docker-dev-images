#!/bin/bash

BUILD_ARGS="--force-rm --pull"
PWD=$(pwd)
PROJECT_NAME=$(basename "${PWD}")

tag() {
  for tag in $2
  do
    docker tag "${PROJECT_NAME}_$1:latest" "sandstein/$1:$tag"
  done

}

tag_version() {
  for tag in $3
  do
    docker tag "${PROJECT_NAME}_$1-$2:latest" "sandstein/$1:$tag"
  done
}

tag_php_version() {
  for tag in $3
  do
    docker tag "${PROJECT_NAME}_php-$1-$2" "sandstein/php:$1-$tag"
  done
}

get_php_version()  {
  docker-compose run --rm "php-$1-$2" php --version | grep "^PHP" | cut -d " " -f2
}

get_node_version() {
  docker-compose run --rm node-$1 node -v| grep "^v" | sed "s/v//"
}


get_python_version() {
  docker-compose run --rm python-$1 python -V| grep "^Python " | sed "s/Python //" | sed 's/\r//'
}

get_mysql_version() {
  docker-compose run --rm "mysql-$1" mysqld --version | cut -d " " -f4
}

get_percona_version() {
  docker-compose run --rm "percona-$1" mysqld --version | cut -d " " -f4
}

get_mariadb_version() {
  docker-compose run --rm "mariadb-$1" mysqld --version | \
    grep --only-matching --perl-regexp "\\d+\.\\d+\.\\d+-MariaDB" | \
    grep --only-matching --perl-regexp "\\d+\.\\d+\.\\d+"  | sed 's/\r//'
}

get_apache_version() {
  docker-compose run --rm "apache-$1" httpd -v | \
    grep --only-matching --perl-regexp "Apache\/\\d+\.\\d+\.\\d+" | \
    grep  --only-matching --perl-regexp "\\d+\.\\d+\.\\d+"  | sed 's/\r//'
}

get_selenium_side_runner_version() {
  docker-compose run --rm selenium-side-runner selenium-side-runner --version | sed 's/\r//'
}

test() {
  echo $PROJECT_NAME;
}

case $1 in

ssh)
# ssh (https://hub.docker.com/_/debian)
docker-compose build ${BUILD_ARGS} ssh
tag "ssh" "11 bullseye latest"
;;

selenium-side-runner)
# selenium-side-runner (https://hub.docker.com/_/node)
docker-compose build ${BUILD_ARGS} selenium-side-runner
tag selenium-side-runner "$(get_selenium_side_runner_version) 14 latest"
;;

apache)
# apache (https://hub.docker.com/_/httpd)
docker-compose build ${BUILD_ARGS} apache-2.4
tag_version "apache" "2.4" "2.4 $(get_apache_version 2.4) latest"
;;

mariadb)
# mariadb (https://hub.docker.com/_/mariadb)
for version in 10.2 10.3 10.4 10.5 10.6 10.7
do
  docker-compose build ${BUILD_ARGS} "mariadb-$version"
done
tag_version "mariadb" "10.2" "10.2 $(get_mariadb_version 10.2)"
tag_version "mariadb" "10.3" "10.3 $(get_mariadb_version 10.3)"
tag_version "mariadb" "10.4" "10.4 $(get_mariadb_version 10.4)"
tag_version "mariadb" "10.5" "10.5 $(get_mariadb_version 10.5)"
tag_version "mariadb" "10.6" "10.6 $(get_mariadb_version 10.6)"
tag_version "mariadb" "10.7" "10.7 $(get_mariadb_version 10.7) latest"
;;

mysql)
# mysql (https://hub.docker.com/_/mysql)
for version in 5.6 5.7 8.0
do
  docker-compose build ${BUILD_ARGS} "mysql-$version"
done
tag_version "mysql" "5.6" "5.6 $(get_mysql_version 5.6)"
tag_version "mysql" "5.7" "5.7  $(get_mysql_version 5.7)"
tag_version "mysql" "8.0" "8.0  $(get_mysql_version 8.0) latest"
;;

percona)
# percona (https://hub.docker.com/r/percona/percona-server)
for version in 5.7 8.0
do
  docker-compose build ${BUILD_ARGS} "percona-$version"
done
tag_version "percona" "5.7" "5.7  $(get_percona_version 5.7)"
tag_version "percona" "8.0" "8.0 $(get_percona_version 5.7) latest"
;;

php)
# php (cli and fpm) (https://hub.docker.com/_/php/)
for type in cli fpm
  do
  for version in 7.3 7.4 8.0 8.1 8.2
  do
    target="php-$type-$version"
    docker-compose build ${BUILD_ARGS} $target
    tag_php_version $type $version "$version $(get_php_version "$type" $version)"
    if [ "${type}" == "cli" ] && [ "${version}" == "8.2" ]; then
      tag_version "php" "$type-$version" "latest"
    fi
  done
done
;;
elasticsearch)
for version in 5.6 6.4 6.8 7.1 7.3 7.6 7.10 7.16 7.17 8.6
do
  docker-compose build ${BUILD_ARGS} elasticsearch-${version}
done
tag_version "elasticsearch" "5.6" "5 5.6 5.6.16"
tag_version "elasticsearch" "6.4" "6.4 6.4.3"
tag_version "elasticsearch" "6.8" "6 6.8 6.8.23"
tag_version "elasticsearch" "7.1" "7.1 7.1.1"
tag_version "elasticsearch" "7.3" "7.3 7.3.2"
tag_version "elasticsearch" "7.6" "7.6 7.6.2"
tag_version "elasticsearch" "7.10" "7.10 7.10.1"
tag_version "elasticsearch" "7.16" "7.16 7.16.3"
tag_version "elasticsearch" "7.17" "7 7.17 7.17.8"
tag_version "elasticsearch" "8.6" "8 8.6 8.6.2 latest"
;;

node)
for version in 11 12 14 16 17 18
do
  docker-compose build ${BUILD_ARGS} node-${version}
  if [ ${version} == "18" ]; then
    tag_version "node" $version "$version $(get_node_version "$version") latest"
  else
    tag_version "node" $version "$version $(get_node_version "$version")"
  fi
done
;;

python)
for version in 3.10
do
  docker-compose build ${BUILD_ARGS} python-${version}
  tag_version "python" $version "$version $(get_python_version "$version") latest"
done
;;

solr)
for version in 7.7 8.9
do
  docker-compose build ${BUILD_ARGS} solr-${version}
done
tag_version "solr" "7.7" "7.7 7.7.3"
tag_version "solr" "8.9" "8.9 8.9.0 latest"
;;

*)
  test
esac