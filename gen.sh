#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
wget -O geneva.py https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/geneva.py

# 使用 dnf 安装依赖包  
sudo dnf install -y python3 python3-devel gcc gcc-c++ git libnetfilter_queue libnetfilter_queue-devel libffi-devel  
  
# 升级 pip3  
pip3 install --upgrade pip  
  
# 使用 pip3 安装 scapy 和 netfilterqueue  
pip3 install scapy netfilterqueue  

iptables   -I OUTPUT -p tcp --sport 443 -j NFQUEUE --queue-num 100
iptables   -I OUTPUT -p tcp --sport 80 -j NFQUEUE --queue-num 100

nohup python3 gen.py -q 100 -w 1 -s 7 -c 0 -n 7 &

# 验证 geneva.py 是否正在运行  
echo "geneva.py install finish, please verify it with [ps -ef|grep geneva]"
