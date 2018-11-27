#!/bin/bash
mysqldump -hIP -uroot -pmima --default-character-set=utf8 jcbase > jcbase-$(date +%y%m%d)
