#!/bin/bash

php_ini_dir="/etc/php5/apache2/php.ini"
user = $1
project_dir = $2

#Install apc
apt-get install make libpcre3-dev
pecl install apc

echo "extension = apc.so" >> $php_ini_dir

echo "apc.shm_size = 64" >> $php_ini_dir
echo "apc.stat = 0" >> $php_ini_dir

service apache2 start

cp /usr/share/doc/php5-apcu /public_html/$project_dir/apc.php


#Install memecache
apt-get install memcached libmemcached-tools
pecl install memcache

echo "extension=memcache.so">> /etc/php5/conf.d/memcache.ini

echo "memcache.hash_strategy=consistent">> /etc/php5/conf.d/memcache.ini

sudo service memcached start
sudo service apache2 restart



#Configure Drupal for use of memcache
cd /home/$user/public_html/$project_dir

drush dl memcache -y
drush en memcache -y

echo "$conf['cache_backends'][] = 'sites/all/modules/memcache/memcache.inc';" >> site/default/settings.php
echo "$conf['cache_default_class'] = 'MemCacheDrupal';" >> site/default/settings.php
echo "$conf['cache_class_cache_form'] = 'DrupalDatabaseCache';" >> site/default/settings.php
echo "$conf['memcache_key_prefix'] = $project_dir . '_mem_key';" >> site/default/settings.php

