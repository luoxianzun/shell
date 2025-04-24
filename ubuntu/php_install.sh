#!/bin/bash
# PHP 8.1 编译安装脚本

# 检查root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用sudo或root用户运行此脚本"
    exit 1
fi

# 安装依赖
apt update
apt install -y libxml2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libonig-dev libssl-dev

# 下载源码
PHP_VERSION="8.1.23"
wget https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz
tar -zxvf php-${PHP_VERSION}.tar.gz
cd php-${PHP_VERSION}

# 编译配置
./configure \
    --prefix=/usr/local/php \
    --with-config-file-path=/usr/local/php/etc \
    --enable-fpm \
    --with-fpm-user=www \
    --with-fpm-group=www \
    --with-mysqli=mysqlnd \
    --with-pdo-mysql=mysqlnd \
    --with-openssl \
    --with-zlib \
    --with-curl \
    --with-gd \
    --enable-mbstring

# 编译安装
make -j$(nproc) && make install

# 创建配置文件
cp php.ini-production /usr/local/php/etc/php.ini
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf

# 修改配置
sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' /usr/local/php/etc/php.ini
sed -i 's/user = www-data/user = www/' /usr/local/php/etc/php-fpm.d/www.conf
sed -i 's/group = www-data/group = www/' /usr/local/php/etc/php-fpm.d/www.conf

# 创建系统服务
cat > /etc/systemd/system/php-fpm.service <<EOF
[Unit]
Description=PHP FastCGI Process Manager
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/php/sbin/php-fpm --nodaemonize
ExecReload=/bin/kill -USR2 \$MAINPID

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
systemctl daemon-reload
systemctl enable --now php-fpm

echo "PHP 安装完成！验证命令：/usr/local/php/bin/php -v"