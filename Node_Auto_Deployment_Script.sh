#!/bin/bash
if [ -e node-v10.11.0-linux-x64.tar.gz ]; then
  echo "node-v10.11.0-linux-x64.tar.gz file has existed."
else
  wget https://nodejs.org/download/release/v10.11.0/node-v10.11.0-linux-x64.tar.gz
fi

tar zxvf node-v10.11.0-linux-x64.tar.gz > /dev/null
mv node-v10.11.0-linux-x64 node && cp -r node /usr/local/

p=`grep NODE_HOME /etc/profile|wc -l`
if [ $p -eq 0 ]; then
  echo "export NODE_HOME=/usr/local/node" >> /etc/profile
  echo "export PATH=\$NODE_HOME/bin:\$PATH" >> /etc/profile
else
  echo "node home has been setted!"
fi

rm -fr node*
source /etc/profile
