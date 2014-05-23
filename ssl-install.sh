#!/bin/bash

# Install OpenSSL
apt-get -y install openssl

# Enable SSL
a2enmod ssl

# restarting apache
service apache2 reload

# Create the virtual host file
cat <<EOF > /etc/apache2/sites-available/ssl-$domain.conf
<IfModule mod_ssl.c>
<VirtualHost *:443>
        ServerAdmin webmaster@localhost

        DocumentRoot /home/$user/public_html/$project_dir
        ServerName $domain
        ServerAlias www.$domain

    #   SSL Engine Switch:
    #   Enable/Disable SSL for this virtual host.
    SSLEngine on

    #   A self-signed (snakeoil) certificate can be created by installing
    #   the ssl-cert package. See
    #   /usr/share/doc/apache2/README.Debian.gz for more info.
    #   If both key and certificate are stored in the same file, only the
    #   SSLCertificateFile directive is needed.
    SSLCertificateFile  /etc/ssl/certs/ssl-cert-snakeoil.pem
    SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

    #   Server Certificate Chain:
    #   Point SSLCertificateChainFile at a file containing the
    #   concatenation of PEM encoded CA certificates which form the
    #   certificate chain for the server certificate. Alternatively
    #   the referenced file can be the same as SSLCertificateFile
    #   when the CA certificates are directly appended to the server
    #   certificate for convinience.
    #SSLCertificateChainFile /etc/apache2/ssl.crt/server-ca.crt

        <Directory /home/$user/public_html/$project_dir/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
    Require all granted
                <IfModule mod_php5.c>
                        php_admin_flag engine on
                </IfModule>
        </Directory>

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel error

        ErrorLog /ssl-abc-error.log
        CustomLog /ssl-abc-access.log combined

</VirtualHost>
</IfModule>
EOF

# enabling site
a2ensite $domain

# restarting apache
service apache2 reload
