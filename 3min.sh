#!/bin/bash
find /data/TrafficLight/real -cmin -3 > info.txt #查找/data/TrafficLight/real目录中3分钟以前的文件，将信息写在info.txt中
grep ".jpg$" infor.txt > info_new.txt #查找info.txt中以“.jpg”结尾的行
#按行读取info_new.txt,赋值给变量d
for d in `awk '{print $1}' info_new.txt`
do
  #移动文件
  mv $d /mnt/jiaqiang/heze/0528/${d:24:20} #${d:24:20}表示截取变量d，从第24个字符截取，取20位
done
