#!/bin/bash

# 设置中国时区（上海）
sudo timedatectl set-timezone Asia/Shanghai

# 安装 chrony 时间同步服务（Ubuntu使用apt）
sudo apt-get update && sudo apt-get install -y chrony

# 备份原始配置文件（注意Ubuntu的配置文件路径不同）
sudo cp /etc/chrony/chrony.conf /etc/chrony/chrony.conf.bak

# 配置中国 NTP 服务器（使用tee命令避免权限问题）
sudo tee /etc/chrony/chrony.conf << EOF
server ntp.ntsc.ac.cn iburst
server cn.pool.ntp.org iburst
pool time.pool.aliyun.com iburst
driftfile /var/lib/chrony/drift
makestep 1.0 3
rtcsync
logdir /var/log/chrony
EOF

# 重启服务（Ubuntu服务名为chrony）
sudo systemctl restart chrony

# 启用并启动服务
sudo systemctl enable --now chrony

# 强制时间同步（立即生效）
sudo chronyc -a makestep

# 检查配置状态
echo -e "\n\033[36m[时区状态]\033[0m"
timedatectl show --property=Timezone

echo -e "\n\033[36m[时间同步状态]\033[0m"
chronyc tracking