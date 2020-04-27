#!/bin/bash
while read photo_file #按行读取文件
do
  i=0
  data=$(base64 "$photo_file") #将图片翻译成base64
  curl -X POST -H "Accept: application/json" -H "Content-Type: application/json;charset=UTF-8" -d @- "url" <<CURL_DATA
  {"request_id":"$i","image":"$data","face_id":"pic$1","is_filter":"0","image_type":"0"}
CURL_DATA #CRUL_DATA是结束符号与EOF一样的意思
  let i=i+1
  echo -e "\n"
done < photo.txt #read读取的文件  
