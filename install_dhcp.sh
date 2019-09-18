#!/bin/bash
ping -c 4 mirrors.aliyun.com >/dev/null 2>&1;case $? in 0) echo "internet is ok!";;1) echo "error: disconnect internet!!!";;esac
wget -O /etc/yum.repos.d/Centos-7.repo http://mirrors.aliyun.com/repo/Centos-7.repo >/dev/null 2>&1 
yum clean all && yum makecache fast >/dev/null 2>&1
yum install -y dhcp >/dev/null 2>&1

cat > /etc/dhcp/dhcpd.conf << EOF
option domain-name "boyun.dhcp.com";
option domain-name-servers 192.168.1.100;

default-lease-time 600;
max-lease-time 7200;

log-facility local7;

subnet 192.168.2.0 netmask 255.255.255.0 {
  range 192.168.2.21 192.168.2.130;
  #option domain-name-servers ns1.internal.example.org;
  #option domain-name "internal.example.org";
  option routers 192.168.2.1;
  #option broadcast-address 10.5.5.31;
  default-lease-time 600;
  max-lease-time 7200;
}
EOF
systemctl enable dhcpd && systemctl start dhcpd
