#!/bin/bash

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
