#!/bin/bash

# Options
# User for which the domain will be set up and the domain that needs to be set up
user=ubuntu
domain=abc.com

# Create public_html directory
mkdir /home/$user/public_html

# Create the virtual host file
cat <<EOF > /etc/apache2/sites-available/$domain
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
 
        DocumentRoot /home/$user/public_html
        ServerName $domain
        ServerAlias www.$domain
 
        <Directory />
                Options FollowSymLinks
                AllowOverride All
        </Directory>
        <Directory /var/www/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride None
                Order allow,deny
                allow from all
        </Directory>
 
        ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
        <Directory "/usr/lib/cgi-bin">
                AllowOverride None
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                Order allow,deny
                Allow from all
        </Directory>
 
        ErrorLog ${APACHE_LOG_DIR}/error.log
 
        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel error
 
        CustomLog ${APACHE_LOG_DIR}/access.log combined
 
    Alias /doc/ "/usr/share/doc/"
    <Directory "/usr/share/doc/">
        Options Indexes MultiViews FollowSymLinks
        AllowOverride None
        Order deny,allow
        Deny from all
        Allow from 127.0.0.0/255.0.0.0 ::1/128
    </Directory>
 
</VirtualHost>
EOF

# Write some php in the demo site
cat <<EOF > /home/$user/public_html/index.php
<?php
echo 'Je Baat !!';
?>
EOF
 
# enabling site
a2ensite $domain
 
# restarting apache
service apache2 reload
