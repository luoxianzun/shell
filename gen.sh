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
  
# 使用 nohup 运行后台进程 
nohup python3 geneva.py -q 100 -w 17 &  
nohup python3 geneva.py -q 101 -w 4 &  
  
# 配置 iptables 规则以将特定 TCP 流量发送到 NFQUEUE  
iptables -I OUTPUT -p tcp --sport 80 --tcp-flags SYN,RST,ACK,FIN,PSH SYN,ACK -j NFQUEUE --queue-num 100  
iptables -I OUTPUT -p tcp --sport 443 --tcp-flags SYN,RST,ACK,FIN,PSH SYN,ACK -j NFQUEUE --queue-num 101  
  
# 验证 geneva.py 是否正在运行  
echo "geneva.py install finish, please verify it with [ps -ef|grep geneva]"