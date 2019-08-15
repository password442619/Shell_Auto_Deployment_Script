#/bin/bash
wget=`command -v wget`
if [ -n $wget ];then
	echo "wget has installed."
else
	yum install wget -y
if
centos7=`cat /etc/redhat-release |grep "CentOS Linux release 7."`
centos6=`cat /etc/redhat-release |grep "CentOS Linux release 6."`
if [ -n $centos7 -a -f '/etc/yum.repos.d/Centos-7' ];then
	wget -O /etc/yum.repos.d/Centos-7.repo http://mirrors.aliyun.com/repo/Centos-7.repo
	echo "ali centos7 yum repo wget successful!"
elif [ -n $centos6 -a -f '/etc/yum.repos.d/Centos-6.repo' ];then
	wget -O /etc/yum.repos.d/Centos-6.repo http://mirrors.aliyun.com/repo/Centos-6.repo
	echo "ali centos6 yum repo wget successful!"
fi
yum clean all && yum makecache fast && yum install -y samba samba-client && systemctl start smb && systemctl enable smb
sed -i 's/SAMBA/BOYUN/g' /etc/samba/smb.conf
sed -i '/passdb backend = tdbsam/a\\tmap to guest = bad user' /etc/samba/smb.conf
mkdir /boyun_samba_share
chmod 777 /boyun_samba_share
cat << EOF >> /etc/samba/smb.conf
[boyun_samba_share]
        comment = boyun
        path = /boyun_samba_share
        browseable = yes
        writeable = yes
        guest ok = yes
	public = yes
EOF
firewall-cmd --add-service=samba --permanent
firewall-cmd --reload
systemctl restart smb

#以上脚本是搭建好了samba服务器，在客户端使用时，编辑/etc/fstab,加入一行，
#例如//192.168.1.4/boyun_samba_share	/home/boyun/samba cifs defaults,guest 0 0
#切记/192.168.1.4/boyun_samba_share中的boyun_samba_share对应smb.conf中你自己加入的项名字，
#就是用中括号扩起来的名字，比如脚本上是[boyun_samba_share]。
#然后安装cifs-utils,用yum命令安装即可。
#执行mount -a。
#执行df -h看是否挂载成功。
