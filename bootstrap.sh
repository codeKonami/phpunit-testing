#!/usr/bin/env bash

apt-get update
apt-get install -y nginx
apt-get install -y php5-fpm php5-dev
sudo apt-get install -y git
sudo apt-get install -y imagemagick
apt-get install -y gearman-job-server libgearman-dev
apt-get install -y php5-mysql
apt-get install -y php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-ming php5-ps php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl php-apc
apt-get install -y supervisor
apt-get install -y vim
apt-get install -y gearman-tools
apt-get install -y supervisor
sudo ln -s /etc/php5/conf.d/mcrypt.ini /etc/php5/mods-available
sudo php5enmod mcrypt
service supervisor restart
sudo apt-get install -y build-essential
sudo apt-get install -y php-pear
pecl install gearman-1.0.3
echo "extension=gearman.so" > /etc/php5/cli/conf.d/gearman.ini
echo 'server {
    client_max_body_size 4M;
    listen   80;
    server_name cakephp.dev;
    access_log /home/cakephp/logs/access.log;
    error_log /home/cakephp/logs/error.log;
    root /home/cakephp/public_html/app/webroot/;
    index  index.php index.html;

    location ~* \.(ico|css|js|gif|jpe?g|png)(\?[0-9]+)?$ {
            expires max;
            log_not_found off;
    }

    location / {
        try_files $uri $uri/ /index.php?$uri&$args;
    }

    location /phpmyadmin {
               root /usr/share/;
               index index.php index.html index.htm;
               location ~ ^/phpmyadmin/(.+\.php)$ {
                       try_files $uri =404;
                       root /usr/share/;
			        include /etc/nginx/fastcgi_params;
			        fastcgi_pass unix:/var/run/php5-fpm.sock;
			        fastcgi_index   index.php;
			        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
               }
               location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
                       root /usr/share/;
               }
     }
     location /phpMyAdmin {
            rewrite ^/* /phpmyadmin last;
     }

    location ~ \.php$ {
        try_files $uri =404;
        include /etc/nginx/fastcgi_params;
        fastcgi_pass unix:/var/run/php5-fpm.sock;
        fastcgi_index   index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    location ^~ /.git/ {
            # only allow lan computer
            deny all;
    }

    location ~* (\.py|\.sql|\.pyc|\.sh)$ {
            deny all;
    }

}' > /etc/nginx/sites-available/cakephp
rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/cakephp /etc/nginx/sites-enabled/cakephp
sed -i 's/127.0.0.1:9000/\/var\/run\/php5-fpm.sock/g' /etc/php5/fpm/pool.d/www.conf
sed -i 's/sendfile on;/sendfile off;/g' /etc/nginx/nginx.conf
service php5-fpm restart
useradd cakephp
mkdir /home/cakephp
ln -fs /vagrant /home/cakephp/public_html
mkdir /home/cakephp/logs
touch /home/cakephp/logs/error.log
touch /home/cakephp/logs/access.log

service nginx start

# Mysql
# -----
# Ignore the post install questions
export DEBIAN_FRONTEND=noninteractive
# Install MySQL quietly
apt-get -q -y install mysql-server-5.5
mysql -uroot -e'CREATE DATABASE cakephp_db;'
