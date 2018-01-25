#!/bin/bash
# elabftw-docker start script

# write config file from env var
db_host=$(grep mysql /etc/hosts | awk '{print $1}')
if [ -z "$db_host" ]; then
    db_host=${DB_HOST}
fi
db_name=${DB_NAME:-elabftw}
db_user=${DB_USER:-elabftw}
db_password=${DB_PASSWORD}
secret_key=${SECRET_KEY}
elab_root='/elabftw/'
server_name=${SERVER_NAME:-localhost}

cat << EOF > /elabftw/config.php
<?php
define('DB_HOST', '${db_host}');
define('DB_NAME', '${db_name}');
define('DB_USER', '${db_user}');
define('DB_PASSWORD', '${db_password}');
define('ELAB_ROOT', '${elab_root}');
define('SECRET_KEY', '${secret_key}');
EOF

# nginx config
echo "daemon off;" >> /etc/nginx/nginx.conf
sed -i -e "s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
sed -i -e "s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf

# php-fpm config
sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php5/fpm/php.ini
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php5/fpm/php.ini
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php5/fpm/pool.d/www.conf

# elabftw
mkdir -p /elabftw/uploads/{tmp,export}
chmod -R 777 /elabftw/uploads
chown -R www-data:www-data /elabftw
chmod -R u+x /elabftw/*

# start all the services
/usr/bin/supervisord -c /etc/supervisord.conf -n
