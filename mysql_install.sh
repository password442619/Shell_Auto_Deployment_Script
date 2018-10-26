#!/bin/bash
mysql -V
if [ $? -eq 0 ]; then
  echo 'mysql has been installed.'
else  
  rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm && yum install -y mysql-community-server && systemctl start mysqld
fi
