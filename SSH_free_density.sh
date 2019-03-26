#!/bin/bash
if [ -e ~/.ssh/ ]; then
  echo ".ssh has exsit."
else
  mkdir -p ~/.ssh/
fi
cd ~/.ssh/
ssh-keygen -t rsa
ssh-copy-id -i ~/.ssh/id_rsa.pub $1@$2
#脚本后跟账号和密码，例如./SSH_free_density.sh root 123456
