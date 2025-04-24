#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# 必须参数检查
SSHPORT=$1
if [ -z "$SSHPORT" ]; then
    echo "Usage: $0 <new_ssh_port>"
    exit 1
fi

# 备份原始配置
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# 安全修改SSH端口（兼容多种配置格式）
sudo sed -i "/^Port/d" /etc/ssh/sshd_config  # 删除所有旧Port配置
echo "Port $SSHPORT" | sudo tee -a /etc/ssh/sshd_config  # 添加新端口
echo "Port 22" | sudo tee -a /etc/ssh/sshd_config        # 保留旧端口作为备份

# 安装配置防火墙（临时放行新旧端口）
sudo apt update && sudo apt install ufw -y
sudo ufw --force reset
sudo ufw default allow incoming  # 设置默认允许策略
sudo ufw allow 22/tcp
sudo ufw allow "$SSHPORT"/tcp
sudo ufw --force enable
sudo ufw reload

# 重启SSH服务（使用正确服务名）
sudo systemctl restart sshd

# 等待10秒让新端口生效
sleep 10

# 验证新端口连通性
if nc -z 127.0.0.1 "$SSHPORT"; then
    echo "新端口 $SSHPORT 验证成功，现在可以移除旧端口"
    sudo sed -i '/Port 22/d' /etc/ssh/sshd_config
    sudo ufw delete allow 22/tcp
    sudo ufw reload
    sudo systemctl restart sshd
else
    echo "警报：新端口 $SSHPORT 无法连通，已自动回滚配置！"
    sudo cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config
    sudo ufw delete allow "$SSHPORT"/tcp
    sudo ufw reload
    sudo systemctl restart sshd
fi

# 后续操作（保持连接时执行）
sudo apt update && sudo apt upgrade -y
sudo apt remove subversion -y && sudo apt install subversion -y
svn --version