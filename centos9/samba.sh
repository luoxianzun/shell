#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

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

# 自动为 www 用户设置 Samba 密码（这里假设密码也是 www）
# 注意：在生产环境中，应该使用更安全的方式来处理密码
(echo "www"; echo "www"; echo "www") | smbpasswd -s -a www

# 将 www 用户添加到 smbusers 文件中，以便它可以作为网络服务的一部分
echo 'www = "network service"' >> /etc/samba/smbusers

# 确保 /etc/rc.d/rc.local 文件存在并可执行，以便在系统启动时运行自定义命令
if [ ! -x /etc/rc.d/rc.local ]; then
    chmod +x /etc/rc.d/rc.local
fi

# 在 rc.local 文件中添加启动 Samba 服务的命令（虽然 systemctl enable 已经做了这一步，但这是为了确保）
echo 'systemctl start smb nmb' >> /etc/rc.d/rc.local

# 设置 /www/wwwroot 目录的权限
chown -R www:www /www/wwwroot
chmod -R 755 /www/wwwroot

# 重启 smb 服务以应用新的配置
systemctl restart smb

# 输出安装成功的消息
echo "Samba install and configuration success."
