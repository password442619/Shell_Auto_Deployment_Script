在 /opt/work目录下

创建fenfa.sh

```
#!/bin/bash  
for p in $(cat /opt/work/ip.txt)
do
ip=$(echo "$p"|cut -f1)
password="Oct11.abc"
expect -c "
 spawn ssh-copy-id -i /root/.ssh/id_rsa.pub root@$ip  
          expect {   
                  \"*yes/no*\" {send \"yes\r\"; exp_continue}   
                  \"*password*\" {send \"$password\r\"; exp_continue}   
                  \"*Password*\" {send \"$password\r\";}   
          }   
  "   
  done    
```

创建ip.txt

```
192.168.10.100
192.168.60.123
192.168.60.124
192.168.10.101
