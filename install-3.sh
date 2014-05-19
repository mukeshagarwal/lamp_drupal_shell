#!/bin/bash

# Options
# PHP Optimizations
php_ini_dir="/etc/php5/apache2/php.ini"
PHP_MEMORY_LIMIT=512M
PHP_MAX_EXECUTION_TIME=60
PHP_MAX_INPUT_TIME=300
PHP_POST_MAX_SIZE=32M
PHP_UPLOAD_MAX_FILESIZE=32M

# Tweak php.ini based on input in options.conf
sed -i 's/^max_execution_time.*/max_execution_time = '${PHP_MAX_EXECUTION_TIME}'/' $php_ini_dir
sed -i 's/^memory_limit.*/memory_limit = '${PHP_MEMORY_LIMIT}'/' $php_ini_dir
sed -i 's/^max_input_time.*/max_input_time = '${PHP_MAX_INPUT_TIME}'/' $php_ini_dir
sed -i 's/^post_max_size.*/post_max_size = '${PHP_POST_MAX_SIZE}'/' $php_ini_dir
sed -i 's/^upload_max_filesize.*/upload_max_filesize = '${PHP_UPLOAD_MAX_FILESIZE}'/' $php_ini_dir
sed -i 's/^expose_php.*/expose_php = Off/' $php_ini_dir

# Install postfix
echo "postfix postfix/main_mailer_type select Internet Site" | debconf-set-selections
echo "postfix postfix/mailname string $HOSTNAME_FQDN" | debconf-set-selections
echo "postfix postfix/destinations string localhost.localdomain, localhost" | debconf-set-selections
aptitude -y install postfix

# Allow mail delivery from localhost only
/usr/sbin/postconf -e "inet_interfaces = loopback-only"

sleep 1
postfix stop
sleep 1
postfix start

