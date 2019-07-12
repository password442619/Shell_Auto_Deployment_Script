
 module.exports = {
     apps: [
         {
             name: 'rdb-read',
             script: 'java',
             args:[
                 '-jar',
                 './rdb-read.jar'
             ],
             cwd: '.',
             interpreter: '',
             error_file: './logs/rdb-read-err.log',
             out_file: './logs/rdb-read-out.log'
         }
     ]
 }
举例apps中的内容：
{
  "name"        : "fis-receiver",  // 应用名称
  "script"      : "./bin/www",  // 实际启动脚本
  "cwd"         : "./",  // 当前工作路径
  "watch": [  // 监控变化的目录，一旦变化，自动重启
    "bin",
    "routers"
  ],
  "ignore_watch" : [  // 从监控目录中排除
    "node_modules", 
    "logs",
    "public"
  ],
  "watch_options": {
    "followSymlinks": false
  },
  "error_file" : "./logs/app-err.log",  // 错误日志路径
  "out_file"   : "./logs/app-out.log",  // 普通日志路径
  "env": {
      "NODE_ENV": "production"  // 环境参数，当前指定为生产环境
  }
}

#pm2 config for tomcat

module.exports = {
        apps: [
                {
                        name: 'map_boundary',
                        script: 'catalina.sh',
                        args:[
                                'run'
                        ],
                        cwd: '.',
                        interpreter: '/bin/bash'
                }
        ]
}

详细的配置文件写法，请参考：
https://pm2.io/doc/zh/runtime/guide/ecosystem-file/

参数解释：
apps:json结构，apps是一个数组，每一个数组成员就是对应一个pm2中运行的应用
name:应用程序名称
cwd:应用程序所在的目录
script:应用程序的脚本路径
log_date_format:
error_file:自定义应用程序的错误日志文件
out_file:自定义应用程序日志文件
pid_file:自定义应用程序的pid文件
instances:启动的线程数量
min_uptime:最小运行时间，这里设置的是60s即如果应用程序在60s内退出，pm2会认为程序异常退出，此时触发重启max_restarts设置数量
max_restarts:设置应用程序异常退出重启的次数，默认15次（从0开始计数）
cron_restart:定时启动，解决重启能解决的问题
watch:是否启用监控模式，默认是false。如果设置成true，当应用程序变动时，pm2会自动重载。这里也可以设置你要监控的文件。
merge_logs:
exec_interpreter:应用程序的脚本类型，默认是nodejs
exec_mode:应用程序启动模式，默认是fork
autorestart:启用/禁用应用程序崩溃或退出时自动重启
vizion:启用/禁用vizion特性(版本控制)
