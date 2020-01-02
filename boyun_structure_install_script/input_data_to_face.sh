#!/bin/bash
username=$1
password=$2
expect << EOF
	set timeout 1
	spawn mysql -uroot -p
	expect {
		"Enter password:" {send "$password\r"; exp_continue;}
	}
	expect "mysql>" {send "use vss;\r";}
	expect "mysql>" {send "source /usr/local/vss/server/vss.sql;\r";}
	expect "mysql>" {send "exit;\r";}
EOF
exit
