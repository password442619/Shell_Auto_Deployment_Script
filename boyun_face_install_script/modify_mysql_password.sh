#!/bin/bash
username=root
password=$1
expect << EOF
	set timeout 1
	spawn mysql -u $username -p 
	expect {
		"Enter password:" {send "$password\r"; exp_continue;}
	}
	expect "mysql>" {send "set password=password(\"Boyun@2019\");\r";}
	expect "mysql>" {send "create database if not exists face;\r";}
	expect "mysql>" {send "create database if not exists fres_test;\r";}
	expect "mysql>" {send "flush privileges;\r;"}
	expect "mysql>" {send "exit;\r";}
EOF
exit
#数据库创库，改密码
