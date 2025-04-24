#!/bin/bash
# Nginx 1.25 编译安装脚本

# 检查root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用sudo或root用户运行此脚本"
    exit 1
fi

# 安装依赖
apt update
apt install -y build-essential libpcre3-dev zlib1g-dev libssl-dev

# 下载源码
NGINX_VERSION="1.25.3"
wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar -zxvf nginx-${NGINX_VERSION}.tar.gz
cd nginx-${NGINX_VERSION}

# 编译配置
./configure \
    --prefix=/usr/local/nginx \
    --user=www \
    --group=www \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_stub_status_module

# 编译安装
make -j$(nproc) && make install

# 创建系统服务
cat > /etc/systemd/system/nginx.service <<EOF
[Unit]
Description=nginx service
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/nginx/sbin/nginx
ExecReload=/usr/local/nginx/sbin/nginx -s reload
ExecStop=/usr/local/nginx/sbin/nginx -s quit
PrivateTmp=true
User=www
Group=www

[Install]
WantedBy=multi-user.target
EOF

# 创建www用户
useradd -M -s /sbin/nologin www

# 启动服务
systemctl daemon-reload
systemctl enable --now nginx

# 防火墙配置
ufw allow 80/tcp
ufw allow 443/tcp
ufw reload

echo "Nginx 安装完成！验证命令：systemctl status nginx"