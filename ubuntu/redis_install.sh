#!/bin/bash
# Redis编译安装+PHP扩展安装

# 检查root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用sudo或root用户运行此脚本"
    exit 1
fi

# 配置变量
REDIS_PASSWORD="YourSecureRedisPass123!"

# 安装依赖
apt update
apt install -y build-essential tcl

# 下载Redis
REDIS_VERSION="7.4.3"
wget https://download.redis.io/releases/redis-${REDIS_VERSION}.tar.gz
tar -zxvf redis-${REDIS_VERSION}.tar.gz
cd redis-${REDIS_VERSION}

# 编译安装
make -j$(nproc) && make install

# 创建配置文件
mkdir -p /etc/redis
cp redis.conf /etc/redis/redis.conf

# 修改配置
sed -i 's/supervised no/supervised systemd/' /etc/redis/redis.conf
echo "maxmemory 256mb" >> /etc/redis/redis.conf
echo "maxmemory-policy allkeys-lru" >> /etc/redis/redis.conf
echo "requirepass $REDIS_PASSWORD" >> /etc/redis/redis.conf  # 添加密码配置

# 创建系统服务
cat > /etc/systemd/system/redis.service <<EOF
[Unit]
Description=Redis In-Memory Data Store
After=network.target

[Service]
User=redis
Group=redis
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
ExecStop=/usr/local/bin/redis-cli -a '$REDIS_PASSWORD' shutdown  # 添加密码参数
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 创建redis用户
useradd -r -s /sbin/nologin redis
chown -R redis:redis /etc/redis

# 启动服务
systemctl daemon-reload
systemctl enable --now redis

# 安装PHP Redis扩展
apt install -y php-dev
pecl install redis
echo "extension=redis.so" >> /usr/local/php/etc/php.ini
systemctl restart php-fpm

echo "Redis 安装完成！验证命令：redis-cli ping"