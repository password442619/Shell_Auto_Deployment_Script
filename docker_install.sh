#!/bin/bash
docker run hello-world
if [ $? -eq 0 ]; then
	echo 'docker has been installed.'
else
	yum install -y yum-utils device-mapper-persistent-data lvm2 && yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo && yum makecache fast && yum -y install docker-ce && systemctl start docker
fi
