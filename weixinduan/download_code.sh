#!/usr/bin/expect
set username "motb"
set passwd "motb1234"
spawn git clone http://gitlab.asoco.com.cn/asoco/asoco-wx-app.git
expect "Username:"
send "$username\n"
expect "Password"
send "$passwd\n"
interact
