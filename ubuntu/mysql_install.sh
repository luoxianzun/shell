#!/bin/bash
# MySQL 5.7 编译修复安装脚本

# 检查root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用sudo或root用户运行此脚本"
    exit 1
fi

# 安装依赖（增加libtirpc-dev）
apt update
apt install -y cmake libncurses5-dev libssl-dev bison libtirpc-dev

# 下载源码（使用官方源码包）
MYSQL_VERSION="5.7.44"
wget https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-${MYSQL_VERSION}.tar.gz
tar -zxvf mysql-${MYSQL_VERSION}.tar.gz
cd mysql-${MYSQL_VERSION}

# 应用补丁文件（修复符号缺失问题）
cat > fix_db_return.patch <<'EOF'
diff --git a/sql/mysqld.cc b/sql/mysqld.cc
index 7c8e8d9..bca8a6d 100644
--- a/sql/mysqld.cc
+++ b/sql/mysqld.cc
@@ -5092,6 +5092,7 @@ static int init_common_variables() {
   opt_log= MY_TEST(opt_log_handlers_list);
 #endif
 
+  DBUG_RETURN(0);
   return 0;
 }
EOF

patch -p1 < fix_db_return.patch

# 编译配置（增加WITH_BOOST路径）
cmake . \
    -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
    -DMYSQL_DATADIR=/data/mysql \
    -DSYSCONFDIR=/etc \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_BOOST=./boost \
    -DDEFAULT_CHARSET=gbk \
    -DDEFAULT_COLLATION=gbk_chinese_ci \
    -DENABLED_LOCAL_INFILE=1 \
    -DCMAKE_CXX_FLAGS="-Wno-error=deprecated-declarations" # 禁用警告

# 编译安装
make -j$(nproc) VERBOSE=1
make install

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