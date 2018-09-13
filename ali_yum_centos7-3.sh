cd /etc/yum.repos.d/
wget  http://mirrors.aliyun.com/repo/Centos-7.repo
yum clean all
yum makecache fast
yum install -y epel-release
