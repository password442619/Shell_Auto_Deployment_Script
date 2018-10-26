#!/bin/bash
docker-compose -v
if [ $? -eq 0 ]; then
  echo 'docker-compose has been installed.'
else
  yum install -y epel-release && yum install -y python-pip && pip install --upgrade pip && pip install docker-compose && docker-compose -v
fi
