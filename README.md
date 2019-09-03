# sandstein - dev images

## ssh
A slim debian with aditional user ssh to use  for port forwarding. To use in own context
add this to your Dockerfile

```dockerfile
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN modify-ids ssh ${USER_ID} ${GROUP_ID}
```

## apache
An apache (2.4) webserver container. Use

```dockerfile
ARG USER_ID=33
ARG GROUP_ID=33
RUN modify-user-ids www-data ${USER_ID} ${GROUP_ID}
```
in your Dockerfile to run it as your current user.

## php
A collection of all mayor PHP versions as fpm and cli. Use 

```dockerfile
ARG USER_ID=33
ARG GROUP_ID=33
RUN modify-user-ids www-data ${USER_ID} ${GROUP_ID}
```

for the fpm containers and 

```dockerfile
ARG USER_ID=33
ARG GROUP_ID=33
RUN modify-user-ids phpcli ${USER_ID} ${GROUP_ID}
```
for the cli containers
### php modules enabled by default
* apcu
* bcmath
* bz2
* calendar
* exif
* gd
* gettext
* imap
* intl
* ldap
* mcrypt
* mysqli
* opcache
* pcntl
* pdo_mysql
* pdo_pgsql
* pgsql
* shmop
* soap
* sockets
* sysvmsg
* sysvsem
* sysvshm
* xmlrpc
* xsl
* zip
* memcached
* mongodb
* redis

## php cli modules customisation

Add the following to your Dockerfiles in order to be able to disable module on build time

```dockerfile
ARG DISABLED_PHP_CLI_MODULES=''
RUN disable-php-modules ${DISABLED_PHP_CLI_MODULES}
```

## php fpm modules customisation    
    
For fpm containers use the following:

```dockerfile
ARG DISABLED_PHP_FPM_MODULES=''
RUN disable-php-modules ${DISABLED_PHP_FPM_MODULES}

```

## mysql,percona,mariadb

Use

```dockerfile
ARG USER_ID=999
ARG GROUP_ID=999
RUN modify-ids mysql ${USER_ID} ${GROUP_ID}
```
for user customisation
