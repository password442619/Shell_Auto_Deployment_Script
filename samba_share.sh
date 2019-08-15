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
        guest ok =yes
EOF
firewall-cmd --add-service=samba --permanent
firewall-cmd --reload
systemctl restart smb