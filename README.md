# sample-for-nginxproxy
This is a sample for quick-automated building application 
  
 
 _Docker with docker-compose should be installed_  
 
 Organize folder structure 
 
 
 ├── dockers \
 └── sites
 
 

 clone repos into dockers folder \
 git clone git@github.com:pasichnikroman/docker-nginx-letsencrypt-sample.git \
 git clone git@github.com:pasichnikroman/sample-for-nginxproxy.git
 
 https://github.com/pasichnikroman/docker-nginx-letsencrypt-sample
 https://github.com/pasichnikroman/sample-for-nginxproxy
 
 run: docker network create -d bridge nginx-proxy \
 to create an extra network

 go to docker-nginx-letsencrypt-sample and run:  docker-compose up -d 
 
 go to sample-for-nginxproxy, rename .env.dist to .env and change all environment variables on your own
 as example
 ### Application's path (absolute or relative)
 
 PROJECT_APP_PATH=./../../sites/example/
 
 
 ###Project prefix 
 
 PROJECT_PREFIX=example
 
 
 ###Nginx proxy
 
 VIRTUAL_PORT=80 \
 VIRTUAL_HOST=example-docker.local \
 VIRTUAL_NETWORK=nginx-proxy 
 
 
 ###php settings
 
 PHP_BUILD_PATH=./phpfpm
 
 
 ###MySQL
 
 MYSQL_ROOT_PASSWORD=pass \
 MYSQL_DATABASE=dbname \
 MYSQL_USER=root1 \
 MYSQL_PASSWORD=pass 
 
 ###open port 
 
 MYSQL_PORT=33065
 
 
 Change Dockerfile for phpfpm , located in ./phpfpm
 ```
 ├── docker-compose.yml
 ├── logs
 │   └── nginx
 │   └── error.log
 ├── nginx
 │   ├── Dockerfile
 ├── phpfpm
 │   └── Dockerfile
 └── volumes
 ├── dumps
 │   └── BACKUP
 └── nginx
      ├── nginx.conf
      └── templates
           ├── default_nginx.tpl
 
 ```
 
 For php 7.1  paste 
 
 ```
 FROM ubuntu:16.04
 MAINTAINER  khanhicetea@gmail.com
 
 RUN apt-get clean && apt-get -y update && apt-get install -y locales curl software-properties-common git \
   && locale-gen en_US.UTF-8
 RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php
 RUN apt-get update
 RUN apt-get install -y --force-yes php7.1-bcmath php7.1-bz2 php7.1-cli php7.1-common php7.1-curl \
                 php7.1-cgi php7.1-dev php7.1-fpm php7.1-gd php7.1-gmp php7.1-imap php7.1-intl \
                 php7.1-json php7.1-ldap php7.1-mbstring php7.1-mcrypt php7.1-mysql \
                 php7.1-odbc php7.1-opcache php7.1-pgsql php7.1-phpdbg php7.1-pspell \
                 php7.1-readline php7.1-recode php7.1-soap php7.1-sqlite3 \
                 php7.1-tidy php7.1-xml php7.1-xmlrpc php7.1-xsl php7.1-zip \
                 php-tideways php-mongodb
 
 RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.1/cli/php.ini
 RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.1/fpm/php.ini
 RUN sed -i "s/display_errors = Off/display_errors = On/" /etc/php/7.1/fpm/php.ini
 RUN sed -i "s/upload_max_filesize = .*/upload_max_filesize = 300M/" /etc/php/7.1/fpm/php.ini
 RUN sed -i "s/post_max_size = .*/post_max_size = 300M/" /etc/php/7.1/fpm/php.ini
 RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.1/fpm/php.ini
 
 RUN sed -i -e "s/pid =.*/pid = \/var\/run\/php7.1-fpm.pid/" /etc/php/7.1/fpm/php-fpm.conf
 RUN sed -i -e "s/error_log =.*/error_log = \/proc\/self\/fd\/2/" /etc/php/7.1/fpm/php-fpm.conf
 RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.1/fpm/php-fpm.conf
 RUN sed -i "s/listen = .*/listen = 9000/" /etc/php/7.1/fpm/pool.d/www.conf
 RUN sed -i "s/;catch_workers_output = .*/catch_workers_output = yes/" /etc/php/7.1/fpm/pool.d/www.conf
 
 RUN curl https://getcomposer.org/installer > composer-setup.php && php composer-setup.php && mv composer.phar /usr/local/bin/composer && rm composer-setup.php
 
 RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 
 EXPOSE 9000
 CMD ["php-fpm7.1"]
 ```
 
 
 
 volumes/nginx/templates/default_nginx.tpl, this template is used for auto-generation magento 2 nginx conf
 
 ## Example configuration:
 ```
 upstream fastcgi_backend {
 
 # use tcp connection
 
 server  {{.PHPFPM_ENV}}:9000;
 
 # or socket
 
 #server   unix:/var/run/php5-fpm.sock;
 
 #server   unix:/var/run/php/php7.0-fpm.sock;
 
 }
 
 server {
 
 client_max_body_size 100M;
 
 listen 80;
 
 server_name {{.VIRTUAL_HOST}};
 
 set $MAGE_ROOT /app;
 
 set $MAGE_MODE developer;

 #}
 
 ## Optional override of deployment mode. We recommend you use the
 
 ## command 'bin/magento deploy:mode:set' to switch modes instead.
 
 ##
 
 ## set $MAGE_MODE default; # or production or developer
 
 ##
 
 ## If you set MAGE_MODE in server config, you must pass the variable into the
 
 ## PHP entry point blocks, which are indicated below. You can pass
 
 ## it in using:
 
 ##
 
 ## fastcgi_param  MAGE_MODE $MAGE_MODE;
 
 ##
 
 ## In production mode, you should uncomment the 'expires' directive in the /static/ location block
 
 root $MAGE_ROOT/pub;
 
 index index.php;
 
 autoindex off;
 
 charset UTF-8;
 
 error_page 404 403 = /errors/404.php;
 
 #add_header "X-UA-Compatible" "IE=Edge";
 
 # PHP entry point for setup application
 
 location /setup {
 
 root $MAGE_ROOT;
 
 location ~ ^/setup/index.php {
 
 ### This fixes the problem:
 
 fastcgi_split_path_info ^(.+?\.php)(/.*)$;
 
 ################################
 
 fastcgi_pass   fastcgi_backend;
 
 fastcgi_index  index.php;
 
 fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
 
 include        fastcgi_params;
 
 }
 
 location ~ ^/setup/(?!pub/). {
 
 deny all;
 
 }
 
 location ~ ^/setup/pub/ {
 
 add_header X-Frame-Options "SAMEORIGIN";
 
 }
 
 }
 
 # PHP entry point for update application
 
 location ~* ^/update($|/) {
 
 root $MAGE_ROOT;
 
 location ~ ^/update/index.php {
 
 fastcgi_split_path_info ^(/update/index.php)(/.+)$;
 
 fastcgi_pass   fastcgi_backend;
 
 fastcgi_index  index.php;
 
 fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
 
 fastcgi_param  PATH_INFO        $fastcgi_path_info;
 
 include        fastcgi_params;
 
 }
 
 # Deny everything but index.php
 
 location ~ ^/update/(?!pub/). {
 
 deny all;
 
 }
 
 location ~ ^/update/pub/ {
 
 add_header X-Frame-Options "SAMEORIGIN";
 
 }
 
 }
 
 location / {
 
 try_files $uri $uri/ /index.php$is_args$args;
 
 }
 
 location /pub/ {
 
 location ~ ^/pub/media/(downloadable|customer|import|theme_customization/.*\.xml) {
 
 deny all;
 
 }
 
 alias $MAGE_ROOT/pub/;
 
 add_header X-Frame-Options "SAMEORIGIN";
 
 }
 
 location /static/ {
 
 # Uncomment the following line in production mode
 
 # expires max;
 
 # Remove signature of the static files that is used to overcome the browser cache
 
 location ~ ^/static/version {
 
 rewrite ^/static/(version\d*/)?(.*)$ /static/$2 last;
 
 }
 
 location ~* \.(ico|jpg|jpeg|png|gif|svg|js|css|swf|eot|ttf|otf|woff|woff2)$ {
 
 add_header Cache-Control "public";
 
 add_header X-Frame-Options "SAMEORIGIN";
 
 expires +1y;
 
 if (!-f $request_filename) {
 
 rewrite ^/static/?(.*)$ /static.php?resource=$1 last;
 
 }
 
 }
 
 location ~* \.(zip|gz|gzip|bz2|csv|xml)$ {
 
 add_header Cache-Control "no-store";
 
 add_header X-Frame-Options "SAMEORIGIN";
 
 expires    off;
 
 if (!-f $request_filename) {
 
 rewrite ^/static/?(.*)$ /static.php?resource=$1 last;
 
 }
 
 }
 
 if (!-f $request_filename) {
 
 rewrite ^/static/?(.*)$ /static.php?resource=$1 last;
 
 }
 
 add_header X-Frame-Options "SAMEORIGIN";
 
 }
 
 location /media/ {
 
 try_files $uri $uri/ /get.php$is_args$args;
 
 location ~ ^/media/theme_customization/.*\.xml {
 
 deny all;
 
 }
 
 location ~* \.(ico|jpg|jpeg|png|gif|svg|js|css|swf|eot|ttf|otf|woff|woff2)$ {
 
 add_header Cache-Control "public";
 
 add_header X-Frame-Options "SAMEORIGIN";
 
 expires +1y;
 
 try_files $uri $uri/ /get.php$is_args$args;
 
 }
 
 location ~* \.(zip|gz|gzip|bz2|csv|xml)$ {
 
 add_header Cache-Control "no-store";
 
 add_header X-Frame-Options "SAMEORIGIN";
 
 expires    off;
 
 try_files $uri $uri/ /get.php$is_args$args;
 
 }
 
 add_header X-Frame-Options "SAMEORIGIN";
 
 }
 
 location /media/customer/ {
 
 deny all;
 
 }
 
 location /media/downloadable/ {
 
 deny all;
 
 }
 
 location /media/import/ {
 
 deny all;
 
 }
 
 # PHP entry point for main application
 
 location ~ (index|get|static|report|404|503)\.php$ {
 
 try_files $uri =404;
 
 fastcgi_pass   fastcgi_backend;
 
 fastcgi_buffers 1024 4k;
 
 fastcgi_param  PHP_FLAG  "session.auto_start=off \n suhosin.session.cryptua=off";
 
 fastcgi_param  PHP_VALUE "memory_limit=768M \n max_execution_time=18000";
 
 fastcgi_read_timeout 600s;
 
 fastcgi_connect_timeout 600s;
 
 fastcgi_index  index.php;
 
 fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
 
 include        fastcgi_params;
 
 }
 
 gzip on;
 
 gzip_disable "msie6";
 
 gzip_comp_level 6;
 
 gzip_min_length 1100;
 
 gzip_buffers 16 8k;
 
 gzip_proxied any;
 
 gzip_types
 
 text/plain
 
 text/css
 
 text/js
 
 text/xml
 
 text/javascript
 
 application/javascript
 
 application/x-javascript
 
 application/json
 
 application/xml
 
 application/xml+rss
 
 image/svg+xml;
 
 gzip_vary on;
 
 # Banned locations (only reached if the earlier PHP entry point regexes don't match)
 
 location ~* (\.php$|\.htaccess$|\.git) {
 
 deny all;
 
 }
 
 }
 ```
 
 
 
 
 
 Run docker-compose up -d 
 
 create hosts in /etc/hosts \
 0.0.0.0 example-docker.local example2-docker.local
 
 
 inside sites folder create  project \
 Example for magento env.xml , database credentials \
 array ( \
 'host' => 'mysql-example', //prefix example from .env file \
 'dbname' => 'dbname', \
 'username' => 'root1', \
 'password' => 'pass', \
 'active' => '1', \
 ),\
 
 
 
 ###useful commands 
 
 docker-compose up -d \
 docker-compose  stop|start|restart nginx \
 
 docker-compose down \
 docker-compose build --no-cache \
 docker-compose up -d --force-recreate \
 docker-compose ps 