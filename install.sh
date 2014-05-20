#!/bin/bash

# Options
# Root password for MySQL
MYSQL_ROOT_PASSWORD=abcd1234
user=ubuntu

# First uninstall any unnecessary packages and ensure that aptitude is installed.
apt-get update
apt-get -y install aptitude
aptitude -y install nano

# Install wget
apt-get -y install wget
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

# Enable apache required modules
a2enmod rewrite actions alias userdir

# Enable SSL
# a2enmod ssl

sh /home/$user/lamp_drupal_shell/install-2.sh
sh /home/$user/lamp_drupal_shell/install-3.sh
sh /home/$user/lamp_drupal_shell/install-4.sh
