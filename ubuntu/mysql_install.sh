#!/bin/bash
# MySQL 5.7 编译安装脚本

# 检查root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用sudo或root用户运行此脚本"
    exit 1
fi

# 安装依赖
apt update
apt install -y cmake libncurses5-dev libssl-dev bison

# 下载源码
MYSQL_VERSION="5.7.44"
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-boost-${MYSQL_VERSION}.tar.gz
tar -zxvf mysql-boost-${MYSQL_VERSION}.tar.gz
cd mysql-${MYSQL_VERSION}

# 编译配置
cmake . \
    -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
    -DMYSQL_DATADIR=/www/mysql \
    -DSYSCONFDIR=/etc \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_BOOST=./boost \
    -DDEFAULT_CHARSET=gbk \
    -DDEFAULT_COLLATION=gbk_chinese_ci \
    -DENABLED_LOCAL_INFILE=1

# 编译安装
make -j$(nproc) && make install

# 创建mysql用户
useradd -M -s /sbin/nologin mysql
mkdir -p /www/mysql
chown -R mysql:mysql /www/mysql

# 初始化数据库
/usr/local/mysql/bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/www/mysql

# 创建配置文件
cat > /etc/my.cnf <<EOF
[mysqld]
port=3399
basedir=/usr/local/mysql
datadir=/www/mysql
socket=/tmp/mysql.sock
character-set-server=gbk
collation-server=gbk_chinese_ci

[client]
default-character-set=gbk
port=3399
socket=/tmp/mysql.sock
EOF

# 创建系统服务
cat > /etc/systemd/system/mysql.service <<EOF
[Unit]
Description=MySQL Server
After=network.target

[Service]
User=mysql
Group=mysql
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf
ExecReload=/bin/kill -HUP \$MAINPID
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# 启动服务
systemctl daemon-reload
systemctl enable --now mysql

# 设置root密码
/usr/local/mysql/bin/mysqladmin -u root password "UMDBPassword1@123"

echo "MySQL 安装完成！验证命令：mysql -P 3399 -u root -p"