
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
https://pm2.io/doc/en/runtime/overview/?utm_source=pm2&utm_medium=website&utm_campaign=rebranding
