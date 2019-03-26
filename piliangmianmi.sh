在 /opt/work目录下

创建fenfa.sh

#!/bin/bash
for p in $(cat /opt/work/ip.txt)
do
    ip=$(echo "$p"|awk -F '[:]' '{print $1}')
    password=$(echo "$p"|awk -F '[:]' '{print $2}')
    expect -c "
    spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@$ip
          expect {
               \"*yes/no*\" {send \"yes\r\"; exp_continue}
               \"*password*\" {send \"$password\r\"; exp_continue}
               \"*Password*\" {send \"$password\r\";}
          }
    "
done

创建ip.txt
192.168.10.100:abc.123456
192.168.60.123:password.
192.168.60.124:Abc.123456
192.168.10.101:Samsung.123
