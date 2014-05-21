#!/bin/bash

# Options
# User for which the domain will be set up and the domain that needs to be set up
user=ubuntu
domain=abc.com

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

        DocumentRoot /home/$user/public_html
        ServerName $domain
        ServerAlias www.$domain

        <Directory /home/$user/public_html/>
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
