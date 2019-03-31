# sandstein/php-docker

## UserId and GroupId modifications

ARG USER_ID=999
ARG GROUP_ID=999
RUN modify-ids mysql ${USER_ID} ${GROUP_ID}

## CLI Modules Customisation

ARG DISABLED_PHP_CLI_MODULES=''
RUN disable-php-modules ${DISABLED_PHP_CLI_MODULES}

## FPM Modules Customisation    
    
ARG DISABLED_PHP_FPM_MODULES=''
RUN disable-php-modules ${DISABLED_PHP_FPM_MODULES}
    
## Modules enabled by default
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
