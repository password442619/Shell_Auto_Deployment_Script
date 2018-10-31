#!/bin/bash
if [ -e node-v8.11.2-linux-x64.tar.gz ]; then
  echo "node-v8.11.2-linux-x64.tar.gz file has existed."
else
  wget https://nodejs.org/download/release/v8.11.2/node-v8.11.2-linux-x64.tar.gz
fi

tar zxvf node-v8.11.2-linux-x64.tar.gz > /dev/null
mv node-v8.11.2-linux-x64 node && cp -r node /usr/local/

p=`grep NODE_HOME /etc/profile|wc -l`
if [ $p -eq 0 ]; then
  echo "export NODE_HOME=/usr/local/node" >> /etc/profile
  echo "export PATH=\$NODE_HOME/bin:\$PATH" >> /etc/profile
else
  echo "node home has been setted!"
fi

source /etc/profile
