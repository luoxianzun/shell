#!/bin/bash

# 检查是否提供了足够的参数
if [ "$#" -ne 2 ]; then
    echo "用法: $0 <samba_用户名> <samba_密码>"
    exit 1
fi

SAMBA_USERNAME=$1
SAMBA_PASSWORD=$2

# Ubuntu 适配修改点 1：使用 apt 包管理器
sudo apt update
sudo apt install samba smbclient -y

# Ubuntu 适配修改点 2：服务名称为 smbd nmbd
sudo systemctl start smbd nmbd
sudo systemctl enable smbd nmbd

# 备份原始配置文件（Ubuntu默认路径相同）
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# 生成新的配置文件（适配Ubuntu默认配置结构）
sudo tee /etc/samba/smb.conf > /dev/null <<EOF
[global]
    workgroup = WORKGROUP
    server string = %h server (Samba, Ubuntu)
    security = user
    map to guest = bad user
    name resolve order = bcast host
    include = /etc/samba/shares.conf

[web]
    comment = Web Directory
    path = /www/wwwroot
    browseable = yes
    read only = no
    guest ok = no
    valid users = $SAMBA_USERNAME
    create mask = 0755
    directory mask = 0755
EOF

# Ubuntu 适配修改点 3：安装 samba-common-bin 包含 smbpasswd
sudo apt install samba-common-bin -y

# 创建系统用户（如果不存在）
if ! id "$SAMBA_USERNAME" &>/dev/null; then
    sudo useradd --system --no-create-home --shell /usr/sbin/nologin "$SAMBA_USERNAME"
fi

# Ubuntu 适配修改点 4：使用 chpasswd 设置密码
echo -e "$SAMBA_PASSWORD\n$SAMBA_PASSWORD" | sudo smbpasswd -a -s "$SAMBA_USERNAME"

# 创建共享目录并设置权限
sudo mkdir -p /www/wwwroot
sudo chown -R www-data:www-data /www/wwwroot
sudo chmod -R 2775 /www/wwwroot  # 设置SGID保持目录权限

# Ubuntu 适配修改点 5：重启服务使用新名称
sudo systemctl restart smbd

# 防火墙配置（如果启用UFW）
sudo ufw allow samba

# 验证配置
echo -e "\n\033[36m[配置验证]\033[0m"
testparm -s
smbclient -L localhost -U $SAMBA_USERNAME%$SAMBA_PASSWORD

echo -e "\n\033[32mSamba 配置完成！用户 $SAMBA_USERNAME 可访问共享路径：//服务器IP/web\033[0m"