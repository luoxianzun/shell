#!/bin/bash

# 设置中国时区（上海）
timedatectl set-timezone Asia/Shanghai

# 安装 chrony 时间同步服务
dnf install -y chrony

# 备份原始配置文件
cp /etc/chrony.conf /etc/chrony.conf.bak

# 配置中国 NTP 服务器（替换默认配置）
cat > /etc/chrony.conf << EOF
server ntp.ntsc.ac.cn iburst
server cn.pool.ntp.org iburst
pool time.pool.aliyun.com iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony
EOF

# 启动并启用服务
systemctl enable --now chronyd

# 强制时间同步（立即生效）
chronyc -a makestep

# 检查配置状态
echo -e "\n\033[36m[时区状态]\033[0m"
timedatectl show --property=Timezone

echo -e "\n\033[36m[时间同步状态]\033[0m"
chronyc tracking
