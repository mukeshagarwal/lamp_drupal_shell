#!/bin/bash

apache_conf_dir="/etc/apache2/apache2.conf"

php_ini_dir="/etc/php5/apache2/php.ini"
PHP_MEMORY_LIMIT=256M
PHP_MAX_EXECUTION_TIME=60
PHP_MAX_INPUT_TIME=300
PHP_POST_MAX_SIZE=32M
PHP_UPLOAD_MAX_FILESIZE=32M

# Server configuration
user=$1
domain=$2
db_pass=$3
project_dir=$4

# First uninstall any unnecessary packages and ensure that aptitude is installed.
apt-get update
apt-get -y install aptitude
aptitude -y install nano

# Install wget
apt-get -y install wget

# Install MySQL
echo "mysql-server mysql-server/root_password password $db_pass" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $db_pass" | debconf-set-selections
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

# Update the userdir.conf file
cat <<EOF > /etc/apache2/mods-enabled/userdir.conf
<IfModule mod_userdir.c>
        UserDir public_html
        UserDir disabled root
  UserDir enabled $user
 
        <Directory /home/*/public_html>
    AllowOverride All
    Options MultiViews Indexes SymLinksIfOwnerMatch
    <Limit GET POST OPTIONS>
      # Apache <= 2.2:
            Order allow,deny
            Allow from all
 
            # Apache >= 2.4:
            #Require all granted
    </Limit>
    <LimitExcept GET POST OPTIONS>
      # Apache <= 2.2:
            Order deny,allow
            Deny from all
 
      # Apache >= 2.4:
      #Require all denied
    </LimitExcept>
        </Directory>
</IfModule>
EOF

# Create public_html directory
mkdir /home/$user/public_html

chown -R ubuntu:www-data /home/$user/public_html

# Create the virtual host file
cat <<EOF > /etc/apache2/sites-available/$domain.conf
<VirtualHost *:80>
        ServerAdmin webmaster@localhost

        DocumentRoot /home/$user/public_html/$project_dir
        ServerName $domain
        ServerAlias www.$domain

        <Directory /home/$user/public_html/$project_dir/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
                <IfModule mod_php5.c>
                        php_admin_flag engine on
                </IfModule>
        </Directory>

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel error

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOF

# Write some php in the demo site
cat <<EOF > /home/$user/public_html/index.php
<?php
echo 'PHP is working !!';
?>
EOF

chown ubuntu:www-data /home/$user/public_html/index.php
 
# enabling site
a2ensite $domain
 
# restarting apache
service apache2 reload

# require all for user directories in apache

# Tweak php.ini based on input in options.conf
sed -i 's/^max_execution_time.*/max_execution_time = '${PHP_MAX_EXECUTION_TIME}'/' $php_ini_dir
sed -i 's/^memory_limit.*/memory_limit = '${PHP_MEMORY_LIMIT}'/' $php_ini_dir
sed -i 's/^max_input_time.*/max_input_time = '${PHP_MAX_INPUT_TIME}'/' $php_ini_dir
sed -i 's/^post_max_size.*/post_max_size = '${PHP_POST_MAX_SIZE}'/' $php_ini_dir
sed -i 's/^upload_max_filesize.*/upload_max_filesize = '${PHP_UPLOAD_MAX_FILESIZE}'/' $php_ini_dir
sed -i 's/^expose_php.*/expose_php = Off/' $php_ini_dir

cat <<EOF > $apache_conf_dir
# This is the main Apache server configuration file.  It contains the
# configuration directives that give the server its instructions.
# See http://httpd.apache.org/docs/2.4/ for detailed information about
# the directives and /usr/share/doc/apache2/README.Debian about Debian specific
# hints.
#
#
# Summary of how the Apache 2 configuration works in Debian:
# The Apache 2 web server configuration in Debian is quite different to
# upstream's suggested way to configure the web server. This is because Debian's
# default Apache2 installation attempts to make adding and removing modules,
# virtual hosts, and extra configuration directives as flexible as possible, in
# order to make automating the changes and administering the server as easy as
# possible.

# It is split into several files forming the configuration hierarchy outlined
# below, all located in the /etc/apache2/ directory:
#
# /etc/apache2/
# |-- apache2.conf
# | --  ports.conf
# |-- mods-enabled
# | |-- *.load
# | -- *.conf
# |-- conf-enabled
# | -- *.conf
#   -- sites-enabled
#   -- *.conf
#
#
# * apache2.conf is the main configuration file (this file). It puts the pieces
#   together by including all remaining configuration files when starting up the
#   web server.
#
# * ports.conf is always included from the main configuration file. It is
#   supposed to determine listening ports for incoming connections which can be
#   customized anytime.
#
# * Configuration files in the mods-enabled/, conf-enabled/ and sites-enabled/
#   directories contain particular configuration snippets which manage modules,
#   global configuration fragments, or virtual host configurations,
#   respectively.
#
#   They are activated by symlinking available configuration files from their
#   respective *-available/ counterparts. These should be managed by using our
#   helpers a2enmod/a2dismod, a2ensite/a2dissite and a2enconf/a2disconf. See
#   their respective man pages for detailed information.
#
# * The binary is called apache2. Due to the use of environment variables, in
#   the default configuration, apache2 needs to be started/stopped with
#   /etc/init.d/apache2 or apache2ctl. Calling /usr/bin/apache2 directly will not
#   work with the default configuration.


# Global configuration
#

#
# ServerRoot: The top of the directory tree under which the servers
# configuration, error, and log files are kept.
#
# NOTE!  If you intend to place this on an NFS (or otherwise network)
# mounted filesystem then please read the Mutex documentation (available
# at <URL:http://httpd.apache.org/docs/2.4/mod/core.html#mutex>);
# you will save yourself a lot of trouble.
#
# Do NOT add a slash at the end of the directory path.
#
#ServerRoot "/etc/apache2"

#
# The accept serialization lock file MUST BE STORED ON A LOCAL DISK.
#
Mutex file:${APACHE_LOCK_DIR} default

#
# PidFile: The file in which the server should record its process
# identification number when it starts.
# This needs to be set in /etc/apache2/envvars
#
PidFile ${APACHE_PID_FILE}

#
# Timeout: The number of seconds before receives and sends time out.
#
Timeout 300

#
# KeepAlive: Whether or not to allow persistent connections (more than
# one request per connection). Set to "Off" to deactivate.
#
KeepAlive On

#
# MaxKeepAliveRequests: The maximum number of requests to allow
# during a persistent connection. Set to 0 to allow an unlimited amount.
# We recommend you leave this number high, for maximum performance.
#
MaxKeepAliveRequests 100

#
# KeepAliveTimeout: Number of seconds to wait for the next request from the
# same client on the same connection.
#
KeepAliveTimeout 5


# These need to be set in /etc/apache2/envvars
User ${APACHE_RUN_USER}
Group ${APACHE_RUN_GROUP}

#
# HostnameLookups: Log the names of clients or just their IP addresses
# e.g., www.apache.org (on) or 204.62.129.132 (off).
# The default is off because it would be overall better for the net if people
# had to knowingly turn this feature on, since enabling it means that
# each client request will result in AT LEAST one lookup request to the
# nameserver.
#
HostnameLookups Off

# ErrorLog: The location of the error log file.
# If you do not specify an ErrorLog directive within a <VirtualHost>
# container, error messages relating to that virtual host will be
# logged here.  If you *do* define an error logfile for a <VirtualHost>
# container, that hosts errors will be logged there and not here.
#
ErrorLog ${APACHE_LOG_DIR}/error.log

#
# LogLevel: Control the severity of messages logged to the error_log.
# Available values: trace8, ..., trace1, debug, info, notice, warn,
# error, crit, alert, emerg.
# It is also possible to configure the log level for particular modules, e.g.
# "LogLevel info ssl:warn"
#
LogLevel warn

# Include module configuration:
IncludeOptional mods-enabled/*.load
IncludeOptional mods-enabled/*.conf

# Include list of ports to listen on
Include ports.conf


# Sets the default security model of the Apache2 HTTPD server. It does
# not allow access to the root filesystem outside of /usr/share and /var/www.
# The former is used by web applications packaged in Debian,
# the latter may be used for local directories served by the web server. If
# your system is serving content from a sub-directory in /srv you must allow
# access here, or in any related virtual host.
<Directory />
  Options FollowSymLinks
  AllowOverride None
  Require all granted
</Directory>

<Directory /usr/share>
  AllowOverride None
  Require all granted
</Directory>

<Directory /var/www/>
  Options Indexes FollowSymLinks
  AllowOverride None
  Require all granted
</Directory>

#<Directory /srv/>
# Options Indexes FollowSymLinks
# AllowOverride None
# Require all granted
#</Directory>




# AccessFileName: The name of the file to look for in each directory
# for additional configuration directives.  See also the AllowOverride
# directive.
#
AccessFileName .htaccess

#
# The following lines prevent .htaccess and .htpasswd files from being
# viewed by Web clients.
#
<FilesMatch "^\.ht">
  Require all denied
</FilesMatch>


#
# The following directives define some format nicknames for use with
# a CustomLog directive.
#
# These deviate from the Common Log Format definitions in that they use %O
# (the actual bytes sent including headers) instead of %b (the size of the
# requested file), because the latter makes it impossible to detect partial
# requests.
#
# Note that the use of %{X-Forwarded-For}i instead of %h is not recommended.
# Use mod_remoteip instead.
#
LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined
LogFormat "%h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
LogFormat "%h %l %u %t \"%r\" %>s %O" common
LogFormat "%{Referer}i -> %U" referer
LogFormat "%{User-agent}i" agent

# Include of directories ignores editors and dpkgs backup files,
# see README.Debian for details.

# Include generic snippets of statements
IncludeOptional conf-enabled/*.conf

# Include the virtual host configurations:
IncludeOptional sites-enabled/*.conf

# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
EOF

# restarting apache
service apache2 reload

