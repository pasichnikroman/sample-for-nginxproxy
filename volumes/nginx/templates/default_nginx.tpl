server {

listen *:80;
server_name {{.VIRTUAL_HOST}};


access_log off;

root /app/pub;
index index.php;


location / {
try_files $uri $uri/ /index.php?$query_string;
}

location ~ \.php$ {

try_files $uri =404;
fastcgi_split_path_info ^(.+\.php)(/.*)$;
fastcgi_read_timeout 600;
fastcgi_index index.php;
fastcgi_pass {{.PHPFPM_ENV}}:9000;
include fastcgi_params;
fastcgi_param PHP_VALUE "memory_limit = 512M";
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
}