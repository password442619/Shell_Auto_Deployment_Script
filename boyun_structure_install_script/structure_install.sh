#!/bin/bash
now_dir=`pwd`
####确认显卡驱动状态和版本####
nvidia_driver=`nvidia-smi|grep -i "Driver Version"`
driver_flag=$?
case $driver_flag in
	0)
		echo "Nvidia Driver Already Installed.";;
	*)
		echo "Nvidia Driver Not Installed,Please install nvidia driver!";;
esac
if [ $driver_flag == 0 ];then
	driver_version=`echo $nvidia_driver|awk -F " " '{print $3}'`
	echo "Driver Version:"$driver_version
else
	echo "Driver Version: ERROR! Please install NVIDIA Driver."
	exit 0
fi
####cuda8.0环境监测###########
have_cuda=`ls /usr/local/|grep -i cuda|wc -l`
if [ -n $have_cuda ] && [ $have_cuda -ge 2 ];then
	cuda_version=`ls /usr/local/|grep -i cuda-8.0`
	echo "CUDA Version:$cuda_version"
	if [ $cuda_version != "cuda-8.0" ];then
		echo "Error:Please install cuda-8.0 environment!"
		exit 0
	fi
else
	echo "Error:No Cuda-8.0 Environment!"
	exit 0
fi
####网络环境监测#############
echo "Network monitoring......"
ping -c 2 www.baidu.com > /dev/null
network_flag=$?
if [ $network_flag == 0 ];then
	echo "Network Environment is OK."
else
	echo "Unabel to connect to the Internet!!Please install mysql,redis,docker,node,pm2 manually."
fi
####Increase yum source#####
operation_system=`uname -r|grep -i "el7.x86_64"`
system_flag=$?
if [ $system_flag == 0 ];then
	if [ -d /etc/yum.repos.d/Bak ];then
		echo "Floder is exist.OK~"
	else
		mkdir /etc/yum.repos.d/Bak
	fi
	check_repofile=`ls /etc/yum.repos.d/|grep CentOS|wc -l`
	if [ $check_repofile != 0 ];then
		mv /etc/yum.repos.d/CentOS* /etc/yum.repos.d/Bak
	fi
	wget -O /etc/yum.repos.d/Centos-7.repo http://mirrors.aliyun.com/repo/Centos-7.repo > /dev/null
	yum clean all && yum makecache fast
else
	echo "Please use CentOS 7.5 operating system."
	exit 0
fi
epel_source=`yum repolist|grep 'epel/x86_64'`
epel_flag=$?
if [ $epel_flag == 0 ];then
	echo "Epel source is ok."
else
	echo "Start install epel source......"
	yum install -y epel-release > /dev/null
	echo "Epel source is OK!"
fi
check_expect=`rpm -qa expect|wc -l`
if [ $check_expect == 1 ];then
	echo "Expect has already installed.OK~"
else
	echo "We will install expect.x86_64......"
	yum install -y expect.x86_64
fi
####mysql57 check####
check_expect=`yum list installed|grep expect|wc -l`
if [ $check_expect == 1 ];then
	echo "expect already has installed.OK~"
else
	yum install -y expect.x86_64 > /dev/null
fi
check_mysql57=`rpm -qa mysql*|wc -l`
if [ $check_mysql57 == 0 ];then
	read -t 20 -n1 -p "Mysql57 is not detected.We will install mysql57 next.Do you want to continue [Y/N]?" answer
	if [ $answer == "Y" ] || [ $answer == "y" ];then
		echo -e "\nWe will install mysql57."
		cd /usr/local/boyun_services/mysql57 && yum install mysql* -y
		rm -rf /usr/local/boyun_services/mysql57
		systemctl start mysqld && systemctl enable mysqld > /dev/null
		init_mysql_message=`grep "temporary password" /var/log/mysqld.log|awk -F " " '{print $11}'`
		touch /usr/local/boyun_services/messages.txt
		modify_mysql_password='Boyun@2019'
cat >> /usr/local/boyun_services/messages.txt << EOF
`date +%Y%m%d` The mysql account: root
`date +%Y%m%d` The mysql password: $modify_mysql_password
EOF
		#modify_mysql_password='Boyun@2019'
		sh $now_dir/modify_mysql_password.sh $init_mysql_message > /dev/null
		echo -e "\nMysql Account and Password: root $modify_mysql_password"
		mysql_conf=`sed -n '/\[mysqld\]/=' /etc/my.cnf`
		mysql_bind=`sed -n '/bind-address=/=' /etc/my.cnf|wc -l`
		mysql_port=`sed -n '/port=/=' /etc/my.cnf|wc -l`
		if [ $mysql_bind == 0 ];then
			sed -i "${mysql_conf}a bind-address=0.0.0.0" /etc/my.cnf
		fi
		if [ $mysql_port == 0 ];then
			sed -i "${mysql_conf}a port=3306" /etc/my.cnf
			systemctl restart mysqld
		fi
	elif [ $answer == "N" ] || [ $answer == "n" ];then
		echo -e "\nPlease install mysql57 manually!"
	else
		echo -e "\nInput Error! Exit."
		exit 0
	fi
else
	echo "MySQL detected,please confirm version 5.7."
	read -p "Please tell me your mysql account:" mysql_account
	read -p "Please tell me your mysql password:" mysql_password
cat >> /usr/local/boyun_services/messages.txt << EOF
`date +%Y%m%d` The mysql account: $mysql_account
`date +%Y%m%d` The mysql password: $mysql_password
EOF
fi
rm -rf /usr/local/boyun_services/mysql57
####redis check####
check_redis=`rpm -qa redis|wc -l`
if [ $check_redis == 0 ];then
	read -n1 -p "Redis is not detected.We will install redis next,Do you want to continue [Y/N]?" redis_answer
	if [ $redis_answer == "Y" ] || [ $redis_answer == "y" ];then
		yum install -y redis.x86_64
		sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis.conf
		systemctl start redis && systemctl enable redis
	elif [ $redis_answer == "N" ] || [ $redis_answer == "n" ];then
		echo -e "\nPlease install redis manually!"
	else
		echo -e "\nInput Error! Exit."
		exit 0
	fi
else
	echo "Your server have redis.We will start redis!"
	systemctl start redis && systemctl enable redis
fi
####clickhouse####
check_clickhouse=`yum list installed|grep clickhouse|wc -l`
if [ $check_clickhouse == 0 ];then
	cd /usr/local/boyun_services/clickhouse-install && yum install -y clickhouse*
else
	echo "Clickhouse is OK~"
fi
max_threads=`grep 'processor' /proc/cpuinfo |sort -u |wc -l`
max_block_size=`sed -n '/<max_block_size>/=' /etc/clickhouse-server/config.xml`
if [ -z $max_block_size ];then
    sed -i "87a <max_block_size>16384</max_block_size>" /etc/clickhouse-server/config.xml
fi
max_threads_cfg=`sed -n '/<max_threads>/=' /etc/clickhouse-server/config.xml`
max_threads=`grep 'processor' /proc/cpuinfo |sort -u |wc -l`
if [ -z $max_threads_cfg ];then
    sed -i "87a <max_threads>$max_threads</max_threads>" /etc/clickhouse-server/config.xml
fi
if [ -d /data/isedb/tmp ];then
	echo "Folder /data/isedb/tmp already exists.OK~"
else
	mkdir -p /data/isedb/tmp
fi
chown -R clickhouse.clickhouse /data/isedb
sed -i '114c <path>/data/isedb/</path>' /etc/clickhouse-server/config.xml
sed -i '117c <tmp_path>/data/isedb/tmp</tmp_path>' /etc/clickhouse-server/config.xml
sed -i '70c <listen_host>::</listen_host>' /etc/clickhouse-server/config.xml
systemctl enable clickhouse-server && systemctl start clickhouse-server
####start install engineering####
####Install dependency Library####
echo "Now we started to install dependency Library"
yum  install java-1.8.0-openjdk.x86_64 autoconf automake gcc gcc-c++ gdb net-tools vim lrzsz zlib-devel bzip2-devel zip unzip libuuid-devel python-devel opencv-devel freetype-devel apr-devel curl-devel tbb-devel  glib2-devel gstreamer1-devel gstreamer1-plugins-base-devel kernel-devel kernel-headers xvidcore-devel python-paramiko python2-xlrd python-xlwt python2-numpy sysstat -y
####Get local IP address####
read -p "Please input your IP address:" ip_address
if [ -z $ip_address ];then
	echo "Error!Please enter the correct IP address."
	exit 0
fi
####service packages insert dict####
cd /usr/local/boyun_services/
ise_value=`ls|grep ise*tar.gz`
cnn_value=`ls|grep -i cnn*tar.gz`
rmmt_value=`ls|grep rmmt*tar.gz`
vas_value=`ls|grep vas*tar.gz`
vss_value=`ls|grep vss*tar.gz`
wmvs_value=`ls|grep wmvs*tar.gz`
wmfs_value=`ls|grep wmfs*tar.gz`
wmzt_value=`ls|grep wmzt*tar.gz`
declare -A boyun_dict
boyun_dict['cnn']=$cnn_value
boyun_dict['ise']=$ise_value
boyun_dict['rmmt']=$rmmt_value
boyun_dict['vas']=$vas_value
boyun_dict['vss']=$vss_value
boyun_dict['wmvs']=$wmvs_value
boyun_dict['wmfs']=$wmfs_value
boyun_dict['wmzt']=$wmzt_value
####decompress service package####
tar zxf ${boyun_dict[cnn]} && rm -f ${boyun_dict[cnn]}
tar zxf ${boyun_dict[ise]} && rm -f ${boyun_dict[ise]}
tar zxf ${boyun_dict[rmmt]} && rm -f ${boyun_dict[rmmt]}
tar zxf ${boyun_dict[vas]} && rm -f ${boyun_dict[vas]}
tar zxf ${boyun_dict[vss]} && rm -f ${boyun_dict[vss]}
tar zxf ${boyun_dict[wmvs]} && rm -f ${boyun_dict[wmvs]}
tar zxf ${boyun_dict[wmfs]} && rm -f ${boyun_dict[wmfs]}
tar zxf ${boyun_dict[wmzt]} && rm -f ${boyun_dict[wmzt]}
###clean packages####
cd /usr/local/boyun_services
chown -R root.root *
mv vss/ /usr/local/
cnn_floder=`ls|grep -i cnn*`
ise_floder=`ls|grep ise_v*`
rmmt_floder=`ls|grep rmmt*`
vas_floder=`ls|grep vas*`
vss_floder=`ls|grep vss*`
wmvs_floder=`ls|grep wmvs*`
wmfs_floder=`ls|grep wmfs*`
wmzt_floder=`ls|grep wmzt*`
declare -A boyun_floder
boyun_floder['cnn']=$cnn_floder
boyun_floder['ise']=$ise_floder
boyun_floder['rmmt']=$rmmt_floder
boyun_floder['vas']=$vas_floder
boyun_floder['vss']=$vss_floder
boyun_floder['wmvs']=$wmvs_floder
boyun_floder['wmfs']=$wmfs_floder
boyun_floder['wmzt']=$wmzt_floder
cd /usr/local/boyun_services/${boyun_floder[cnn]} && rm -f nohup.out core.* *.log
cd /usr/local/boyun_services/${boyun_floder[ise]} && rm -f nohup.out logs/* hwinfo.dat fcse.lic
cd /usr/local/boyun_services/${boyun_floder[rmmt]} && rm -f nohup.out
cd /usr/local/boyun_services/${boyun_floder[vas]} && rm -f nohup.out logs/*
cd /usr/local/boyun_services/${boyun_floder[vss]} && rm -f nohup.out logs/*
cd /usr/local/boyun_services/${boyun_floder[wmvs]} && rm -f nohup.out logs/*
cd /usr/local/boyun_services/${boyun_floder[wmfs]} && rm -f nohup.out logs/*
cd /usr/local/boyun_services/${boyun_floder[wmzt]} && rm -f nohup.out logs/*
####cnn config####
chmod +w /usr/local/boyun_services/${boyun_floder[cnn]}/person.cfg
cat > /usr/local/boyun_services/${boyun_floder[cnn]}/person.cfg << EOF
[cnn_model]
dir = person-model/
model_def = person_reid.prototxt
model_weight = 20180327_iter_80000.caffemodel
resultblob_name = pool5/7x7_s2
[server]
gpuid=0
listen_port=9980
nthreads=16
EOF
chmod +w /usr/local/boyun_services/${boyun_floder[cnn]}/vehicle.cfg
cat > /usr/local/boyun_services/${boyun_floder[cnn]}/vehicle.cfg << EOF
[cnn_model]
dir = vehicle-model/
model_def = deploy.prototxt
model_weight = carreid_model_resnet50_lr0.005_2_iter_800000.caffemodel
resultblob_name = global_pool
[server]
gpuid=0
listen_port=9981
nthreads=16
EOF
####ise_d.cfg####
if [ -d /data/isedb ];then
	echo "Folder /data/isedb already exists.OK~"
else
	mkdir -p /data/isedb/
fi
if [ -d /data/rocksdb ];then
	echo "Folder /data/rocksdb already exists.OK~"
else
	mkdir -p /data/rocksdb/
fi
chmod +w /usr/local/boyun_services/${boyun_floder[ise]}/ise_d.cfg
cat > /usr/local/boyun_services/${boyun_floder[ise]}/ise_d.cfg << EOF
[engine]
db_dir = /data/isedb

[rocksdb]
path = /data/rocksdb

[clickhouse]
ip = $ip_address
port = 9000

[log]
max_size_mb = 30
max_count = 15
level = debug

[server]
raw_tcp_listen_port = 2007
allow_ip_filter = *.*.*.*
EOF
####rmmt.cfg####
chmod +w /usr/local/boyun_services/${boyun_floder[rmmt]}/rmmt.cfg
cat > /usr/local/boyun_services/${boyun_floder[rmmt]}/rmmt.cfg << EOF
[shm]
#共享内存的唯一标识符
resource = Rmmt_shm_1
#共享内存大小，单位KB
size_kb = 60000000 
#共享内存检测垃圾回收间隔
GC_timeval = 14

[server]
#Tcp Server的地址及端口号
addr = ip://0.0.0.0:7700
EOF
####vas.cfg####
chmod +w /usr/local/boyun_services/${boyun_floder[vas]}/vas.cfg
cat > /usr/local/boyun_services/${boyun_floder[vas]}/vas.cfg << EOF
[gateway]
ip = 
port = 0 

[local]
ip = $ip_address

#rtsp重连配置参数，重连上限和重连等待时间
[reconnect]
count = 30
time = 60000

#zookeeper相关配置
[engine]
host = 192.168.4.187:2181
path = /root/192.168.4.247:2011/module/vas/vas-001
interval = 5000

[log]
#日志级别, 只能为debug、info、error 之一
level = debug
#单个日志文件大小上限，单位MB
max_size_mb = 30
#日志最大个数
max_count = 15
EOF
####vss.cfg####
chmod +w /usr/local/boyun_services/${boyun_floder[vss]}/vss.cfg
cat > /usr/local/boyun_services/${boyun_floder[vss]}/vss.cfg << EOF
[server]
#认证服务的地址，格式为ip:port
reco_auth_server =
#算法基本目录
algo_base_dir = ./
#Tcp Server的地址及端口号
rmmt_cmd_server = ip://0.0.0.0:3002
#最大结构化路数
max_pvc_num = 20

[gpu]
#结构化检测跟踪gpu配置，支持单一显卡配置多次如0,0 或0,1,0,1,0,1(2*1080Ti+)
video_pvc = 0,0
#结构化识别gpu配置，支持单一显卡配置多次,显存较大可配置2到4个(如0,1,1(2*1080Ti+))低>性能显卡配置1—2次
video_recog = 0 
#图像结构化识别gpu配置,比较占用gpu显存(3GB左右),如果用不到可不配置(置空)视频结构化大
数据必须配置，
#通常仅配置一块显卡且只一次，有较大量图像结构化可配置多卡多次
image_recog = 0 

#结构化检测跟踪gpu batch配置双数4或6(高性能显卡)
pvc_batch = 4 
#结构化识别gpu batch配置双数4或6(高性能显卡)
recog_batch = 4 

[engine]
#zookeeper服务地址
host = 192.168.4.187:2181
#当前服务在zookeeper中的地址标识
path = /root/192.168.4.247:2011/module/vss/vss-001
#当前服务与zookeeper的保活间隔
interval = 5000

[log]
#日志级别, 只能为debug、info、error 之一
level = info
#单个日志文件大小上限，单位MB
max_size_mb = 30
#日志最大个数
max_count = 15
EOF
####wmvs.cfg####
chmod +w /usr/local/boyun_services/${boyun_floder[wmvs]}/wmvs.cfg
cat > /usr/local/boyun_services/${boyun_floder[wmvs]}/wmvs.cfg << EOF
[server]
#Http Server 端口，默认9084
ws_port = 9084
#Tcp Server的地址及端口号
vst_addr = ip://0.0.0.0:3005

[engine]
#zookeeper服务地址
host = 192.168.4.187:2181
#当前服务在zookeeper中的地址标识
path = /root/192.168.4.247:2011/module/wmvs/wmvs-001
#当前服务与zookeeper的保活间隔
interval = 5000

[log]
#日志级别, 只能为debug、info、error 之一
level = info
#单个日志文件大小上限，单位MB
max_size_mb = 30
#日志最大个数
max_count = 15
EOF
####wmfs.cfg####
if [ -d /data/data_wmzt/image_data/ ];then
	echo "Folder /data/data_wmzt/image_data/ already exists.OK~"
else
	mkdir -p /data/data_wmzt/image_data/
fi
chmod +w /usr/local/boyun_services/${boyun_floder[wmfs]}/wmfs.cfg
cat > /usr/local/boyun_services/${boyun_floder[wmfs]}/wmfs.cfg << EOF
[server]
http_port = 9083

[storage]
init_para = /data/data_wmzt/image_data/

[engine]
host = 192.168.4.218:2181
path = /root/192.168.4.218:2011/module/wmfs/wmfs-001
interval = 5000

[log]
#日志级别, 只能为debug、info、error 之一
level = error
#单个日志文件大小上限，单位MB
max_size_mb = 30
#日志最大个数
max_count = 15
EOF
####wmzt.cfg####
chmod +w /usr/local/boyun_services/${boyun_floder[wmzt]}/wmzt.cfg
cat > /usr/local/boyun_services/${boyun_floder[wmzt]}/wmzt.cfg << EOF
[server]
#Http Server 端口
http_port = 8711

[storage]
#图片路径
path = /data/data_wmzt/image_data/

[ise]
#ise服务的ip
ip = $ip_address
#ise服务的端口
port = 2007

[extr]
#CnnExtractor服务的ip
ip = 127.0.0.1
#CnnExtractor服务的端口（用于行人和人骑车）
person_port = 9980
#CnnExtractor服务的端口（用于车辆）
vehicle_port = 9981


[gpu]
#GPU解码方式，-1为软解，0为硬解
decode = -1

[video]
#ip配置本机ip，不能配置127.0.0.1
ip = $ip_address
#wmvs的Http Server 端口
port = 9084
#视频路径
path = 

[redis]
#redis服务的ip
ip = 127.0.0.1
#redis服务的端口
port = 6379

[engine]
#zookeeper服务地址
host = 192.168.4.218:2181
#当前服务在zookeeper中的地址标识
path = /root/192.168.4.218:2011/component/wmzt/wmzt-001
#当前服务与zookeeper的保活间隔
interval = 5000

[log]
#日志级别, 只能为debug、info、error 之一
level = info
#单个日志文件大小上限，单位MB
max_size_mb = 30
#日志最大个数
max_count = 15
EOF

####Install structure plate server####
sh $now_dir/input_data_to_face.sh root Boyun@2019 > /dev/null
mv /usr/local/boyun_services/ffmpeg /usr/local/bin/
if [ -x /usr/local/bin/ffmpeg ];then
	echo "ffmpeg executable.OK~"
else
	chmod +x /usr/local/bin/ffmpeg
fi
tomcat=`ls /usr/local/vss/server/|grep apache`
tar zxf /usr/local/vss/server/$tomcat -C /usr/local/vss/server/
tar zxf /usr/local/vss/server/vss.tar.gz -C /usr/local/vss/server/
rm -f /usr/local/vss/server/$tomcat
rm -f /usr/local/vss/server/vss.tar.gz
mv /usr/local/vss/server/vss /usr/local/vss/server/ROOT
cd /usr/local/vss/server/
tar zxf /usr/local/vss/web/dist.tar.gz -C /usr/local/vss/web/
rm -f /usr/local/vss/web/dist.tar.gz
find /usr/local/vss/ -name ".*" -exec rm -rf {} \;
rm -fr /usr/local/vss/server/apache-tomcat-8.0.36/webapps/ROOT/
mv /usr/local/vss/server/ROOT /usr/local/vss/server/apache-tomcat-8.0.36/webapps/
if [ -d /data/webVideo ];then
	echo "Floder /data/webVideo already exists.OK~"
else
	mkdir -p /data/webVideo
fi
sed -i '138c <Context docBase ="/data/webVideo/" path ="/data/webVideo" debug ="0" reloadable ="true"/>' /usr/local/vss/server/apache-tomcat-8.0.36/conf/server.xml
cat > /usr/local/vss/server/apache-tomcat-8.0.36/webapps/ROOT/WEB-INF/classes/application.properties << EOF
jdbc.driver=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://127.0.0.1:3306/vss?characterEncoding=UTF-8
jdbc.username=root
jdbc.password=Boyun@2019

wmzt.server=$ip_address
wmzt.server.port=8711
wmfe.server=192.168.1.101
wmfe.server.port=8712

ds.initialSize=1
ds.minIdle=1
ds.maxActive=20

ds.maxWait=60000
ds.timeBetweenEvictionRunsMillis=60000
ds.minEvictableIdleTimeMillis=300000

ffmpeg.path=/usr/local/bin/ffmpeg

face.db.name=hisense_face
min.sim=0.8
face.videosourceids=

video.path=/data/webVideo


token.timeout = 1200

app.code = 100009

operateLog.code = VSS

ftp.service=$ip_address
ftp.service.port=21
ftp.service.uid=da
ftp.service.pwd=boyun2019
ftp.service.url=/var/www/da

livepreview.host=$ip_address
livepreview.port=8712
pic.server.port=9083
pic.server.url=/wmzt_image

vedio.service.host=$ip_address
vedio.service.port=8080

frame.skip=1
keep.fps=true

bigdate.server=192.168.1.201
bigdate.server.port=18088
bigdate.server.address=bigdata_rest

analysis.server=192.168.1.86
analysis.server.port=2015

control.server=192.168.1.201
control.server.port=18888

ais.server=192.168.1.85
ais.server.port=8090

redis.host=127.0.0.1
redis.port=6379
redis.password=
redis.pool.maxTotal=500
redis.pool.maxIdle=50
redis.pool.maxWaitMillis=1000
redis.pool.testOnBorrow=true
redis.pool.testOnReturn=true
redis.pool.testWhileIdle=true
EOF
####Install structure plate web####
check_nginx=`yum list installed |grep nginx|wc -l`
if [ $check_nginx == 1 ];then
	yum install -y nginx
fi
cat > /usr/local/vss/web/dist/static/config/config.prod.js << EOF
'use strict'

var _global = {}
_global.config = { 
  NODE_ENV: 'production',
  ADD_CASE_AIS: 'true',
  API_HOST: 'http://$ip_address:8080/',
  HOME_URL: '/home',
  LOGIN_URL :'login',
  mapOptions: {
    tileUrl: 'http://online{s}.map.bdimg.com/onlinelabel/?qt=tile&x={x}&y={y}&z={z}&styles=pl&scaler=1&p=1',
    mapInitCenter: [120.380134, 36.3012],
    mapInitLevel: 12
  },  
}
EOF
cat > /etc/nginx/conf.d/vss.conf << EOF
server {
      listen       8900;
      root /usr/local/vss/web/dist;
      server_name vss;
      location / {
          try_files \$uri \$uri/ /index.html last;
      }
      location = /50x.html {
          root   html;
      }
}
EOF
systemctl start nginx && systemctl enable nginx
systemctl stop firewalld && systemctl disable firewalld
setenforce 0
####start file####
touch /usr/local/boyun_services/start.txt
cat >> /usr/local/boyun_services/start.txt << EOF
cd /usr/local/boyun_services/${boyun_floder[cnn]} && nohup ./CnnExtractor person.cfg &
cd /usr/local/boyun_services/${boyun_floder[cnn]} && nohup ./CnnExtractor vehicle.cfg &
cd /usr/local/boyun_services/${boyun_floder[ise]} && nohup ./ise_face &
cd /usr/local/boyun_services/${boyun_floder[rmmt]} && nohup ./rmmt &
cd /usr/local/boyun_services/${boyun_floder[vss]} && nohup ./vss &
cd /usr/local/boyun_services/${boyun_floder[vfs]} && nohup ./vfs &
cd /usr/local/boyun_services/${boyun_floder[wmvs]} && nohup ./wmvs &
cd /usr/local/boyun_services/${boyun_floder[wmfs]} && nohup ./wmfs &
cd /usr/local/boyun_services/${boyun_floder[wmzt]} && nohup ./wmzt &
/usr/local/vss/server/apache-tomcat-8.0.36/bin/startup.sh
nginx -s reload
#服务启动后执行一下ise_db_v2.1.5.py脚本，此脚本为初始化clickhouse数据库的脚本。
EOF
