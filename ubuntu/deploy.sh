#!/bin/bash
# 一键部署脚本：LEMP+Redis (Ubuntu 22.04)
# 执行方式：curl -sL https://raw.githubusercontent.com/luoxianzun/shell/main/ubuntu/deploy.sh | sudo bash

set -e  # 遇到错误立即退出

# 定义组件安装顺序和脚本URL
declare -A SCRIPTS=(
    [mysql]="https://raw.githubusercontent.com/luoxianzun/shell/main/ubuntu/mysql_install.sh"
    [nginx]="https://raw.githubusercontent.com/luoxianzun/shell/main/ubuntu/nginx_install.sh"
    [php]="https://raw.githubusercontent.com/luoxianzun/shell/main/ubuntu/php_install.sh"
    [redis]="https://raw.githubusercontent.com/luoxianzun/shell/main/ubuntu/redis_install.sh"
    [test]="https://raw.githubusercontent.com/luoxianzun/shell/main/ubuntu/test_site.sh"
)

# 顺序执行安装
for component in mysql nginx php redis test; do
    echo -e "\n\033[34m[正在安装 ${component^^}]\033[0m"
    wget -qO- ${SCRIPTS[$component]} | bash -s
done

# 最终状态检查
echo -e "\n\033[32m[部署完成]\033[0m"
systemctl status mysql nginx php-fpm redis