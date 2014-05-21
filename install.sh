#!/bin/bash

# Options
# MYSQL_ROOT_PASSWORD=abcd1234
user=ubuntu
domain=abc.com
php_ini_dir="/etc/php5/apache2/php.ini"
PHP_MEMORY_LIMIT=256M
PHP_MAX_EXECUTION_TIME=60
PHP_MAX_INPUT_TIME=300
PHP_POST_MAX_SIZE=32M
PHP_UPLOAD_MAX_FILESIZE=32M

project_url=git@github.com:cupertinoconsulting/gauss.git
project_dir=gauss
# user=ubuntu
# project_dir=kabootr
db_user=root
db_pass=abcd1234
db_name=gauss
project_remote_user=ubuntu
project_remote_ip=ip-54-204-133-118
project_files=files.tar.gz
project_db=gauss.sql.gz
project_db_dump=gauss.sql
server_conf=/etc/apache2/sites-available/$domain
secure_key=/home/$user/.ssh/apitest.pem
project_branch=develop
files_url=http://api.transfuse.io/sites/default/files/05-21-2014_gauss-prod-files.tar.gz
db_url=http://api.transfuse.io/sites/default/files/05-21-2014_gauss-prod-db.sql.gz

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
 
# enabling site
a2ensite $domain
 
# restarting apache
service apache2 reload

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

# Clone the project in public_hrml directory
cd /home/$user/public_html
git clone $project_url $project_dir

# Pull the code form given branch
# cd /home/$user/public_html/$project_dir
# git pull origin $project_branch
# git checkout develop

# Copy the db and files from remote and store in tmp folder
mkdir /home/$user/tmp
# scp -i $secure_key $project_remote_user@$project_remote_ip:/home/$project_remote_user/$project_files /home/$user/tmp/
# scp -i $secure_key $project_remote_user@$project_remote_ip:/home/$project_remote_user/$project_db /home/$user/tmp/

#Donwalod the files by wget
wget -o /home/$user/tmp/$project_files $files_url
wget -o /home/$user/tmp/$project_db $db_url

# Extract the files and copy to drupal files folder
tar -xzvf /home/$user/tmp/$project_files -C /home/$user/public_html/$project_dir/sites/default/

# Create a databse
mysql -u$db_user -p$db_pass -e "create database $db_name;"
gunzip /home/$user/tmp/$project_db
mysql -u$db_user -p$db_pass $db_name < /home/$user/tmp/$project_db_dump


# Update the settings.php file

php /home/$user/lamp_drupal_shell/update-settings.php $user $project_dir $db_user $db_pass $db_name

# Correct the file permission of drupal 
bash /home/$user/lamp_drupal_shell/fix-permissions.sh --drupal_path=/home/$user/public_html/$project_dir --drupal_user=$user

# sh /home/$user/lamp_drupal_shell/install-2.sh
# sh /home/$user/lamp_drupal_shell/install-3.sh
# sh /home/$user/lamp_drupal_shell/install-4.sh
