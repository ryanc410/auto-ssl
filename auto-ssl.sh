#!/usr/bin/env bash
##########################################
# Author: Ryan C https://github.com/ryanc410
# Date: 10/21/2021
# Description: Secures Apache with a Lets Encrypt SSL Cert
# Version: 3.0
##########################################
E_CODE=$?
APACHE_LOG_DIR=/var/log/apache2
##########################################
function header()
{
    clear>&3
    echo "##################################">&3
    echo "#     APACHE AUTO SSL SCRIPT     #">&3
    echo "##################################">&3
    echo "">&3
}
function set_domain()
{
    header
    echo "Enter the FQDN that you want to secure with Lets Encrypt:">&3
    read FQDN
}
function logall()
{
    exec 3>&1 4>&2
    trap 'exec 2>&4 1>&3' 0 1 2 3
    exec 1>apache_auto_ssl.log 2>&1
}
function error()
{
    echo "A full log can be found at $PWD/apache_auto_ssl.log">&3
}
##########################################
logall

if [[ $EUID != 0 ]]; then
    header
    echo "Script must be ran with root privileges..">&3
    error
    sleep 3
    exit 1
else
    netstat -anp | grep apache2 | grep 80
    if [[ $E_CODE != 0 ]]; then
        header
        echo "This script requires the Apache Web Server. Could not find an active Apache installation.">&3
        error
        sleep 3
        exit 2
    fi
fi

set_domain

host "$FQDN"
while [[ $E_CODE != 0 ]]; do
    header
    echo "The domain you entered, $FQDN, could not be validated."
    sleep 2
    echo "Check the spelling and try again."
    sleep 3
    set_domain
done

header
echo "The Apache Auto SSL Install script will now begin, this may take some time..">&3

a2enmod ssl headers http2

apt install certbot -y

openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

mkdir -p /var/lib/letsencrypt/.well-known
chgrp www-data /var/lib/letsencrypt
chmod g+s /var/lib/letsencrypt

cat > /etc/apache2/conf-available/letsencrypt.conf <<- _EOF_
Alias /.well-known/acme-challenge/ "/var/lib/letsencrypt/.well-known/acme-challenge/"
<Directory "/var/lib/letsencrypt/">
    AllowOverride None
    Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec
    Require method GET POST OPTIONS
</Directory>
_EOF_

cat > /etc/apache2/conf-available/ssl-params.conf <<- _EOF_
SSLProtocol             all -SSLv3 -TLSv1 -TLSv1.1
SSLCipherSuite          ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
SSLHonorCipherOrder     off
SSLSessionTickets       off
SSLUseStapling On
SSLStaplingCache "shmcb:logs/ssl_stapling(32768)"
SSLOpenSSLConfCmd DHParameters "/etc/ssl/certs/dhparam.pem"
Header always set Strict-Transport-Security "max-age=63072000"
_EOF_

a2enconf letsencrypt ssl-params

systemctl reload apache2

certbot certonly --agree-tos --non-interactive --email admin@"$FQDN" --webroot -w /var/lib/letsencrypt/ -d "$FQDN" -d www."$FQDN"

if [[ $E_CODE != 0 ]]; then
    header
    echo "The SSL Certificate could not be issued for $FQDN..">&3
    sleep 3
    echo "Make sure your DNS records are configured correctly. For DNS configuration examples, execute the script with -h, --help.">&3
    error
    sleep 3
    exit 3
else
    header
    echo "SSL Certficiate was successfully installed on $FQDN!">&3
    sleep 3
fi

echo "Finishing up...">&3

cat > /etc/apache2/sites-available/"$FQDN"-ssl.conf <<- _EOF_
<VirtualHost *:443>
    Protocols h2 http/1.1
    ServerName $FQDN
    DocumentRoot /var/www/$FQDN
    ErrorLog $APACHE_LOG_DIR/$FQDN-error.log
    CustomLog $APACHE_LOG_DIR/$FQDN-access.log combined
    SSLEngine On
    SSLCertificateFile /etc/letsencrypt/live/$FQDN/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/$FQDN/privkey.pem
</VirtualHost>
_EOF_

mkdir /var/www/"$FQDN"

cp /var/www/html/index.html /var/www/"$FQDN"/

a2ensite "$FQDN"-ssl.conf

systemctl reload apache2

if [[ -f /etc/letsencrypt/live/$FQDN/fullchain.pem ]] && [[ -f /etc/letsencrypt/live/$FQDN/privkey.pem ]]; then
    header
    echo "SSL Certificate installed successfully.">&3
    error
    exit 0
else
    header
    echo "SSL Installation failed..">&3
    error
    exit 1
fi
