#!/usr/bin/expect
username=$1
password=$2
expect << EOF
	set timeout 1
	spawn mysql -uroot -p
	expect {
		"Enter password:" {send "$password\r"; exp_continue;}
	}
	expect "mysql>" {send "use face;\r";}
	expect "mysql>" {send "source /usr/local/fas/server/face-1.3.5R.sql;\r";}
	expect "mysql>" {send "exit;\r";}
EOF
exit
