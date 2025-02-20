#!/bin/bash

# 检查是否提供了足够的参数
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <samba_username> <samba_password>"
    exit 1
fi

SAMBA_USERNAME=$1
SAMBA_PASSWORD=$2

# 安装 Samba 和相关客户端工具
dnf install samba samba-client -y

# 启动 smb 和 nmb 服务，并设置开机自启
systemctl start smb nmb
systemctl enable smb nmb

# 备份原始的 smb.conf 文件
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# 创建新的 smb.conf 文件内容
cat <<EOF >/etc/samba/smb.conf
[global]
    server string = Web Samba Server
    security = user
    encrypt passwords = yes
    smb passwd file = /etc/samba/smbpasswd

[web]
    workgroup = WWW
    netbios name = WWW
    path = /www/wwwroot
    browseable = yes
    writable = yes
EOF

# 检查是否存在 smbpasswd 命令，如果不存在则安装 samba-common-tools 包
if ! command -v smbpasswd &> /dev/null; then
    dnf install samba-common-tools -y
fi

# 使用提供的用户名和密码自动设置 Samba 密码
(echo "$SAMBA_PASSWORD"; echo "$SAMBA_PASSWORD") | smbpasswd -s -a "$SAMBA_USERNAME"

# 将 Samba 用户添加到 smbusers 文件中（如果需要）
# 注意：这通常不是必需的，除非你有特定的用户映射需求
# echo "$SAMBA_USERNAME = \"network service\"" >> /etc/samba/smbusers

# 设置 /www/wwwroot 目录的权限（确保 www 用户和组已经存在）
chown -R www:www /www/wwwroot
chmod -R 755 /www/wwwroot

# 重启 smb 服务以应用新的配置
systemctl restart smb

# 输出安装和配置成功的消息
echo "Samba install and configuration success for user $SAMBA_USERNAME."
