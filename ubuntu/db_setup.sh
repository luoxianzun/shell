#!/bin/bash
# 数据库初始化脚本
# 执行方式：sudo bash db_setup.sh

# 配置变量
DB_HOST="localhost"
DB_PORT=3399
DB_NAME="baidu"
DB_USER="baidu"
DB_PASS="UMDBPassword1@123!"
ROOT_PASS="UMDBPassword1@123"  # 需要与手动设置的root密码一致

# 检查root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "请使用sudo或root用户运行此脚本"
    exit 1
fi

# 验证MySQL连接
if ! mysql -u root -h $DB_HOST -P $DB_PORT -p$ROOT_PASS -e "SELECT 1" >/dev/null 2>&1; then
    echo "MySQL连接失败，请检查："
    echo "1. MySQL服务状态 (systemctl status mysql)"
    echo "2. root密码是否正确"
    echo "3. 端口号是否匹配"
    exit 1
fi

# 创建数据库
mysql -u root -h $DB_HOST -P $DB_PORT -p$ROOT_PASS <<EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET gbk COLLATE gbk_chinese_ci;
CREATE USER '$DB_USER'@'%' IDENTIFIED WITH mysql_native_password BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';
FLUSH PRIVILEGES;
EOF

# 验证结果
echo "数据库配置完成，验证信息："
mysql -u $DB_USER -h $DB_HOST -P $DB_PORT -p$DB_PASS -e "SHOW DATABASES;"