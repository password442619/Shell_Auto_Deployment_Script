#!/bin/bash
yum install expect pcre zlib openssl openssl-devel -y > /dev/null
####################Nginx####################################
yum makecache fast > /dev/null
yum install gcc pcre-devel zlib-devel -y > /dev/null
wget http://nginx.org/download/nginx-1.10.2.tar.gz > /dev/null
tar zxvf nginx-1.10.2.tar.gz > file.txt
cd nginx-1.10.2
./configure && make && make install > /dev/null
cd ..
cat > /usr/local/nginx/conf/nginx.conf << EOF
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       9000;
        server_name  localhost;

        location / {
            root   /root/work/asoco-wx-app/dist;
            index  index.html;
        }
        location /api {
			proxy_pass  http://111.3.68.233:40043/;
			proxy_set_header Host $host:$server_port;
			proxy_set_header Cookie $http_cookie;
			proxy_set_header X-Real-IP $remote_addr;
			proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        location /weather {
            		proxy_pass  http://192.168.1.178:8090/;
			proxy_set_header Host $host:$server_port;
			proxy_set_header Cookie $http_cookie;
			proxy_set_header X-Real-IP $remote_addr;
			proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
	}
}
EOF
wget https://nodejs.org/download/release/v8.11.2/node-v8.11.2-linux-x64.tar.gz
tar zxvf node-v8.11.2-linux-x64.tar.gz > /dev/null
mv node-v8.11.2-linux-x64 node && cp -r node /usr/local/
cat >> /etc/profile << EOF
export NODE_HOME=/usr/local/node
export PATH=\$NODE_HOME/bin:\$PATH
EOF
source /etc/profile

/mnt/download_code.sh

mkdir /root/work
cp -r asoco-wx-app /root/work/asoco-wx-app
cd /root/work/asoco-wx-app/
npm install -g npm
npm -v
node -v
npm run build
/usr/local/nginx/sbin/nginx
