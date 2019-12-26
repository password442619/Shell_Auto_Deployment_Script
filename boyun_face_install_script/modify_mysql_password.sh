#!/bin/bash
username=root
password=Boyun@2019
expect << EOF
	set timeout 1
	spawn mysql -u $username -p 
	expect {
		"Enter password:" {send "$password\r"; exp_continue;}
	}
	expect "mysql>" {send "set password=password(\"Boyun@2019\");\r";}
	expect "mysql>" {send "create database face;\r";}
	expect "mysql>" {send "create database fres_test;\r";}
	expect "msyql>" {send "grant all privileges on *.* to 'root'@'%' identified by 'Boyun@2019' with grant option;\r";}
	expect "mysql>" {send "flush privileges;\r"}
	expect "mysql>" {send "exit;\r";}
EOF
exit
