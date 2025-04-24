#!/bin/bash
# 网站测试配置脚本

# 检查root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用sudo或root用户运行此脚本"
    exit 1
fi

# 配置变量
SITE_DOMAIN="baidu.com"
WEB_ROOT="/www/wwwroot/$SITE_DOMAIN"
MYSQL_PASS="UMDBPassword1@123"

# 创建目录
mkdir -p $WEB_ROOT
chown -R www:www $WEB_ROOT

# Nginx配置
cat > /usr/local/nginx/conf/conf.d/${SITE_DOMAIN}.conf <<EOF
server {
    listen 80;
    server_name $SITE_DOMAIN www.$SITE_DOMAIN;
    root $WEB_ROOT;

    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/run/php-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    access_log /www/logs/nginx/${SITE_DOMAIN}_access.log;
    error_log /www/logs/nginx/${SITE_DOMAIN}_error.log;
}
EOF

# 创建测试文件
cat > $WEB_ROOT/index.php <<EOF
<?php
phpinfo();

// MySQL测试
\$mysqli = new mysqli('127.0.0.1', 'root', '$MYSQL_PASS', '', 3399);
if (\$mysqli->connect_error) {
    die('MySQL连接失败: ' . \$mysqli->connect_error);
}
echo '<h3>MySQL连接成功</h3>';

// Redis测试
try {
    \$redis = new Redis();
    \$redis->connect('127.0.0.1', 6379);
	\$redis->auth('YourSecureRedisPass123!');
    echo '<h3>Redis连接成功</h3>';
} catch (Exception \$e) {
    die('Redis连接失败: ' . \$e->getMessage());
}
EOF

# 重启服务
systemctl restart nginx php-fpm

echo "测试站点已配置！访问地址：http://$(curl -4s icanhazip.com)"