在 /mnt目录下，前提要有expect命令

创建fenfa.sh

#!/bin/bash
for a in $(cat /mnt/ip.txt)
do
	ip=$(echo $a|awk -F '[:]' '{print $1}')
	password=$(echo $a|awk -F '[:]' '{print $2}')
	
	expect -c "
	spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@$ip
	expect {
		\"*yes/no*\" {send \"yes\r\"; exp_continue;}
		\"*password*\" {send \"$password\r\";}
		}
	expect eof
	"
done

创建ip.txt，用来记录要做免密的主机的IP和密码。
192.168.10.100:abc.123456
192.168.60.123:password.
IP:密码
