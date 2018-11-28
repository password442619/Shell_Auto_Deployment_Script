#!/bin/bah
mysqldump -hIP -ucount -pmima --default-character-set=utf8 etl > /storage/databak/etl-$(date +%y%m%d).sql
mysqldump -hIP -ucount -pmima --default-character-set=utf8 easyreport2> /storage/databak/easyreport2-$(date +%y%m%d).sql
mysqldump -hIP -ucount -pmima --default-character-set=utf8 video > /storage/databak/video-$(date +%y%m%d).sql
mysqldump -hIP -ucount -pmima --default-character-set=utf8 jcbase > /storage/databak/jcbase-$(date +%y%m%d).sql
mysqldump -hIP -ucount -pmima --default-character-set=utf8 bluezone_alarm > /storage/databak/bluezone_alarm-$(date +%y%m%d).sql
mysqldump -hIP -ucount -pmima --default-character-set=utf8 bluezone_dec > /storage/databak/bluezone_dec-$(date +%y%m%d).sql
mysqldump -hIP -ucount -pmima --default-character-set=utf8 bluezone_enterprise > /storage/databak/enterprise-$(date +%y%m%d).sql
mysqldump -hIP -ucount -pmima --default-character-set=utf8 bluezone_emergency > /storage/databak/bluezone_emergency-$(date +%y%m%d).sql
cd /storage/databak/
tar czf /storage/databak/data-$(date +%y%m%d).tar.gz *-$(date +%y%m%d).sql
rm -f blue* e* jcbase* video*

#crontab -l 产看cron策略，crontab -e 修改cron策略
