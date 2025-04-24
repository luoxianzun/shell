#!/bin/bash
# LEMP+Redis自动化部署脚本
# 测试环境：Ubuntu 22.04 LTS

# 检查root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用sudo或root用户运行此脚本"
    exit 1
fi

# 配置变量
MYSQL_ROOT_PASSWORD="UMDBPassword1@123"
PHP_USER="www"
SITE_DOMAIN="baidu.com"
WEB_ROOT="/www/wwwroot/$SITE_DOMAIN"
MYSQL_PORT=3399

# 安装准备
apt update
apt install -y curl software-properties-common gnupg2

# 添加第三方仓库
## MySQL 5.7
wget https://dev.mysql.com/get/mysql-apt-config_0.8.28-1_all.deb
DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt-config_0.8.28-1_all.deb
apt update

## PHP 8.1
add-apt-repository -y ppa:ondrej/php
## Nginx
curl -fsSL https://nginx.org/keys/nginx_signing.key | gpg --dearmor > /etc/apt/trusted.gpg.d/nginx.gpg
echo "deb [arch=amd64] http://nginx.org/packages/mainline/ubuntu/ $(lsb_release -cs) nginx" > /etc/apt/sources.list.d/nginx.list

# 安装核心组件
apt update
apt install -y \
    nginx \
    mysql-server=5.7.* \
    php8.1-fpm php8.1-mysql php8.1-redis php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-zip \
    redis-server

# 配置MySQL 5.7
systemctl stop mysql
cat > /etc/mysql/conf.d/custom.cnf <<EOF
[mysqld]
port = $MYSQL_PORT
bind-address = 0.0.0.0
default_authentication_plugin=mysql_native_password
innodb_buffer_pool_size=128M
max_connections=100
character-set-server=gbk
collation-server=gbk_chinese_ci
init_connect = 'SET NAMES gbk'

[client]
port = $MYSQL_PORT
default-character-set = gbk
EOF

systemctl start mysql

# mysql防火墙配置
ufw allow $MYSQL_PORT/tcp
ufw reload

mysql -u root -h 127.0.0.1 -P $MYSQL_PORT -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PASSWORD'; FLUSH PRIVILEGES;"

# 配置PHP 8.1
sed -i "s/^user =.*/user = $PHP_USER/" /etc/php/8.1/fpm/pool.d/www.conf
sed -i "s/^group =.*/group = $PHP_USER/" /etc/php/8.1/fpm/pool.d/www.conf
sed -i "s/^;cgi.fix_pathinfo=.*/cgi.fix_pathinfo=0/" /etc/php/8.1/fpm/php.ini
systemctl restart php8.1-fpm

# 配置Nginx
mkdir -p $WEB_ROOT
cat > /etc/nginx/sites-available/$SITE_DOMAIN <<EOF
server {
    listen 80;
    server_name $SITE_DOMAIN www.$SITE_DOMAIN;
    root $WEB_ROOT;

    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }

    access_log /www/logs/nginx/${SITE_DOMAIN}_access.log;
    error_log /www/logs/nginx/${SITE_DOMAIN}_error.log;
}
EOF

ln -s /etc/nginx/sites-available/$SITE_DOMAIN /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
systemctl restart nginx

# 配置Redis
sed -i "s/^supervised no/supervised systemd/" /etc/redis/redis.conf
echo "maxmemory 256mb" >> /etc/redis/redis.conf
echo "maxmemory-policy allkeys-lru" >> /etc/redis/redis.conf
systemctl restart redis

# 防火墙设置
ufw allow 'Nginx Full'
ufw allow OpenSSH
ufw --force enable

# 创建测试文件
cat > $WEB_ROOT/index.php <<EOF
<?php
phpinfo();

// MySQL连接测试
\$mysqli = new mysqli('localhost', 'root', '$MYSQL_ROOT_PASSWORD');
if (\$mysqli->connect_error) {
    die('MySQL连接失败: ' . \$mysqli->connect_error);
}
echo '<h3>MySQL连接成功</h3>';

// Redis测试
try {
    \$redis = new Redis();
    \$redis->connect('127.0.0.1', 6379);
    echo '<h3>Redis连接成功</h3>';
} catch (Exception \$e) {
    die('Redis连接失败: ' . \$e->getMessage());
}
EOF

chown -R $PHP_USER:$PHP_USER $WEB_ROOT

# 输出安装摘要
echo "==================================================="
echo "安装完成！请访问 http://$(curl -4s icanhazip.com)"
echo "---------------------------------------------------"
echo "MySQL root密码: $MYSQL_ROOT_PASSWORD"
echo "网站根目录: $WEB_ROOT"
echo "PHP运行用户: $PHP_USER"
echo "Nginx配置文件: /etc/nginx/sites-available/$SITE_DOMAIN"
echo "==================================================="