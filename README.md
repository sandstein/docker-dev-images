# sandstein/php-docker



## CLI Customisation

RUN source /usr/local/bin/disable_php_modules && \
    disablePhpModules $DISABLED_PHP_CLI_MODULES

RUN source /usr/local/bin/modify_ids \
    modifyUserId phpcli $USER_ID \
    modifyGroupId phpcli $GROUP_ID
    
## FPM Customisation    
    
RUN source /usr/local/bin/disable_php_modules && \
    disablePhpModules $DISABLED_PHP_FPM_MODULES

RUN source /usr/local/bin/modify_ids \
    modifyUserId phpcli $USER_ID \
    modifyGroupId phpcli $GROUP_ID
       
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
