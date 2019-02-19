#!/bin/bash
wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-18.03.1.ce-1.el7.centos.x86_64.rpm
yum install -y docker-ce-18.03.1.ce-1.el7.centos.x86_64.rpm
systemctl start docker
systemctl enable docker
touch /etc/default/docker
echo "DOCKER_OPTS=\"\$DOCKER_OPTS --registry-mirror=http://f2d6cb40.m.daocloud.io\"" > /etc/default/docker
systemctl restart docker
docker pull jenkins/jenkins
#用阿里云的容器镜像服务，阿里云可用支付宝登录
