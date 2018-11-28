#!/bin/bash
find . -type f -mtime +3 -exec rm {} \;  #删除三天之前的文件
find . -type f -mmin +180 -exec rm {} \;  #删除三小时之前的文件
find . -type f -mtime +3   #列出三天之前的文件
find . -type f -mmin +180 #列出三小时之前的文件
