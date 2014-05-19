#!/bin/bash

# Options
# Root password for MySQL
MYSQL_ROOT_PASSWORD=abcd1234

# First uninstall any unnecessary packages and ensure that aptitude is installed.
apt-get update
apt-get -y install aptitude
aptitude -y install nano

# Install MySQL
echo "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD" | debconf-set-selections
aptitude -y install mysql-server mysql-client

# Install Apache2
aptitude -y install apache2

# Install PHP5 support
aptitude -y install php5 libapache2-mod-php5 php-apc php5-mysql php5-dev php5-curl php5-gd php-pear php5-mcrypt php5-xmlrpc

# Install OpenSSL
# apt-get -y install openssl

# Install sendmail
aptitude -y install sendmail

# Enable mod_rewrite  
a2enmod rewrite

# Enable SSL
# a2enmod ssl

