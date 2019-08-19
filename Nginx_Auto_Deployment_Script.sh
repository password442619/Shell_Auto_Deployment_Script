#/bin/bash
yum clean all && yum makecache fast > /dev/null
yum install gcc pcre-devel zlib-devel -y > /dev/null
wget http://nginx.org/download/nginx-1.14.2.tar.gz > /dev/null
tar zxvf nginx-1.14.2.tar.gz > file.txt
cd nginx-1.14.2
./configure && make && make install > /dev/null
/usr/local/nginx/sbin/nginx
ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx
