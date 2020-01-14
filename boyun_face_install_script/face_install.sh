#!/bin/bash
now_dir=`pwdx $$|awk -F " " '{print $2}'`
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
		echo "Floder is already exist.OK~"
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
epel_source=`yum repolist|grep epel`
epel_flag=$?
if [ $epel_flag == 0 ];then
	echo "Epel source is ok."
else
	echo "Start install epel source......"
	yum install -y epel-release > /dev/null
	echo "Epel source is OK!"
fi
check_expect=`rpm -qa expect|wc -l`
if [ $check_expect == 0 ];then
	yum install -y expect.x86_64 > /dev/null
fi
####mysql57 check####
check_mysql57=`rpm -qa mysql*|wc -l`
if [ $check_mysql57 == 0 ];then
	read -t 20 -n1 -p "Mysql57 is not detected.We will install mysql57 next.Do you want to continue [Y/N]?" answer
	if [ $answer == "Y" ] || [ $answer == "y" ];then
		echo -e "\nWe will install mysql57."
		cd /usr/local/boyun_services/mysql57 && yum install mysql* -y
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
####start install engineering####
####Install dependency Library####
echo "Now we started to install dependency Library"
yum  install java-1.8.0-openjdk.x86_64 autoconf automake gcc gcc-c++ gdb net-tools vim lrzsz zlib-devel bzip2-devel zip unzip libuuid-devel python-devel opencv-devel freetype-devel apr-devel curl-devel tbb-devel  glib2-devel gstreamer1-devel gstreamer1-plugins-base-devel kernel-devel kernel-headers xvidcore-devel python-paramiko python2-xlrd python-xlwt python2-numpy sysstat -y
####Get local IP address####
read -p "Please input your IP address:" ip_address
####service packages insert dict####
cd /usr/local/boyun_services/
ise_value=`ls|grep ise*tar.gz`
rmmt_value=`ls|grep rmmt*tar.gz`
vas_value=`ls|grep vas*tar.gz`
vfs_value=`ls|grep vfs*tar.gz`
wmvs_value=`ls|grep wmvs*tar.gz`
wmfs_value=`ls|grep wmfs*tar.gz`
wmfe_value=`ls|grep wmfe*tar.gz`
declare -A boyun_dict
boyun_dict['ise']=$ise_value
boyun_dict['rmmt']=$rmmt_value
boyun_dict['vas']=$vas_value
boyun_dict['vfs']=$vfs_value
boyun_dict['wmvs']=$wmvs_value
boyun_dict['wmfs']=$wmfs_value
boyun_dict['wmfe']=$wmfe_value
####decompress service package####
tar zxf ${boyun_dict[ise]} -C /usr/local/boyun_services/ && rm -f ${boyun_dict[ise]}
tar zxf ${boyun_dict[rmmt]} -C /usr/local/boyun_services/ && rm -f ${boyun_dict[rmmt]}
tar zxf ${boyun_dict[vas]} -C /usr/local/boyun_services/ && rm -f ${boyun_dict[vas]}
tar zxf ${boyun_dict[vfs]} -C /usr/local/boyun_services/ && rm -f ${boyun_dict[vfs]}
tar zxf ${boyun_dict[wmvs]} -C /usr/local/boyun_services/ && rm -f ${boyun_dict[wmvs]}
tar zxf ${boyun_dict[wmfs]} -C /usr/local/boyun_services/ && rm -f ${boyun_dict[wmfs]}
tar zxf ${boyun_dict[wmfe]} -C /usr/local/boyun_services/ && rm -f ${boyun_dict[wmfe]}
###clean packages####
chown -R root.root *
cd /usr/local/boyun_services
ise_floder=`ls|grep ise*`
rmmt_floder=`ls|grep rmmt*`
vas_floder=`ls|grep vas*`
vfs_floder=`ls|grep vfs*`
wmvs_floder=`ls|grep wmvs*`
wmfs_floder=`ls|grep wmfs*`
wmfe_floder=`ls|grep wmfe*`
declare -A boyun_floder
boyun_floder['ise']=$ise_floder
boyun_floder['rmmt']=$rmmt_floder
boyun_floder['vas']=$vas_floder
boyun_floder['vfs']=$vfs_floder
boyun_floder['wmvs']=$wmvs_floder
boyun_floder['wmfs']=$wmfs_floder
boyun_floder['wmfe']=$wmfe_floder
cd /usr/local/boyun_services/${boyun_floder[ise]} && rm -f nohup.out logs/* hwinfo.dat fcse.lic
cd /usr/local/boyun_services/${boyun_floder[rmmt]} && rm -f nohup.out
cd /usr/local/boyun_services/${boyun_floder[vas]} && rm -f nohup.out logs/*
cd /usr/local/boyun_services/${boyun_floder[vfs]} && rm -f nohup.out logs/*
cd /usr/local/boyun_services/${boyun_floder[wmvs]} && rm -f nohup.out logs/*
cd /usr/local/boyun_services/${boyun_floder[wmfs]} && rm -f nohup.out logs/*
cd /usr/local/boyun_services/${boyun_floder[wmfe]} && rm -f nohup.out logs/*
####ise_d.cfg####
mkdir -p /data/ise_facedb/
chmod +w /usr/local/boyun_services/${boyun_floder[ise]}/ise_d.cfg
cat > /usr/local/boyun_services/${boyun_floder[ise]}/ise_d.cfg << EOF
[engine]
db_dir = /data/ise_facedb/

mn_retrieve_cores = 8;

[server]
raw_tcp_listen_port = 2018
allow_ip_filter = *.*.*.*

[log]
max_size_mb = 30
max_count = 15
level = info

[cuda_cdvs]
enable = 0 
ip = 127.0.0.1
port = 2201
conn_tmo = 4000
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
####vfs2.cfg####
chmod +w /usr/local/boyun_services/${boyun_floder[vfs]}/vfs2.cfg
cat > /usr/local/boyun_services/${boyun_floder[vfs]}/vfs2.cfg << EOF
[server]
#服务ip和端口绑定配置
rmmt_cmd_server = ip://0.0.0.0:3004
#最大支持分析路数
max_num = 30
#检测最小值
min_size=35
#最小人脸分辨率
min_w=30
min_h=30
#最小质量分
min_score=0.6

[gpu]
#特征模型gpu配置，可配置多显卡(如:0,1)，不支持单gpu配置多次
cnn=0
#检测模型gpu配置，可配置多显卡(如:0,1)，不支持单gpu配置多次
detect=0
#质量检测模型gpu配置，可配置多显卡(如:0,1)，不支持单gpu配置多次
quality=0

[log]
#日志级别 debug,info,error
level = info
#最大日志文件大小
max_size_mb = 30
#最大日志文件数量
max_files = 15
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
mkdir -p /data/data_wmzt/image_data/
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
####wmfe.cfg####
chmod +w /usr/local/boyun_services/${boyun_floder[wmfe]}/wmfe.cfg
cat > /usr/local/boyun_services/${boyun_floder[wmfe]}/wmfe.cfg << EOF
[server]
#接收http信令端口
http_port = 8712
cvx_font = simhei.ttf

[storage]
#图片存储地址
path = /data/data_wmzt/image_data/

[ise]
#连接ise_face ip 及端口
ip = $ip_address
port = 2018

[gpu]
#是否使用gpu
decode = -1

[video]
#ip配置本机ip，不能配置127.0.0.1
ip = $ip_address
port = 9084
path = 

[redis]
#redis服务相关参数配置
ip = $ip_address
port = 6379

[sqldb]
#sql服务相关配置
db_type=mysql
db_conn_url=127.0.0.1:3306/fres_test
db_uname=root
db_pswd=Boyun@2019
db_init_paras=set charset utf8

[gy_face]
#贵阳项目配置选项
enable = 0
tcp_port=1001
facedata_db=facedb_data
star_db=gy_face_star
rank_db=gy_face_rank
passersby_db=gy_face_passersby

[log]
#日志级别, 只能为debug、info、error 之一
level = debug
#单个日志文件大小上限，单位MB
max_size_mb = 30
#日志最大个数
max_count = 30
EOF

####Install face plate####
mkdir -p /usr/local/fas/server/temp
mv /usr/local/boyun_services/face_plate/* /usr/local/fas/server
mv /usr/local/boyun_services/ffmpeg /usr/local/bin/
chmod +x /usr/local/bin/ffmpeg
sh $now_dir/input_data_to_face.sh root Boyun@2019 > /dev/null
cat > /usr/local/fas/server/application.yml << EOF
spring:
  profiles:
    active: dev 
  redis:
    timeout: 50000
server:
  port: 8600
  version: 1.3.5R
mysql:
  database: face
  host: 127.0.0.1
  port: 3306
  username: root
  password: Boyun@2019
redis:
  database: 0
  host: $ip_address
  port: 6379
  password:
faceserver:
  host: $ip_address
  port: 8712
  url: http://\${faceserver.host}:\${faceserver.port}
  image-prefix: http://\${faceserver.host}:9083/wmzt_image?uid=
  video-url: http://\${faceserver.host}:9084/wmzt_flv?
  upload-file: http://\${faceserver.host}:9083
  startrtsp: http://\${faceserver.host}:8713
file:
  upload:
    temp: /usr/local/fas/server/temp/
  download:
    staticPath:
    webUrl:
  transcoding:
    path: /usr/local/bin/ffmpeg
hw:
  retina:
    device:
      port: 8600
      extraUrl: /huawei/getDeviceInfo
EOF
####start file####
touch /usr/local/boyun_services/start.txt
cat >> /usr/local/boyun_services/start.txt << EOF
cd /usr/local/boyun_services/${boyun_floder[ise]} && nohup ./ise_face &
cd /usr/local/boyun_services/${boyun_floder[rmmt]} && nohup ./rmmt &
cd /usr/local/boyun_services/${boyun_floder[vas]} && nohup ./vas &
cd /usr/local/boyun_services/${boyun_floder[vfs]} && nohup ./vfs &
cd /usr/local/boyun_services/${boyun_floder[wmvs]} && nohup ./wmvs &
cd /usr/local/boyun_services/${boyun_floder[wmfs]} && nohup ./wmfs &
cd /usr/local/boyun_services/${boyun_floder[wmfe]} && nohup ./wmfe &
cd /usr/local/fas/server/ && nohup java -jar face-1.3.5R.jar &
EOF
