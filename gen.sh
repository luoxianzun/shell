#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
wget -O gen.py https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/gen.py
yum install -y python3 python3-devel gcc gcc-c++ git libnetfilter* libffi-devel
pip3 install --upgrade pip
pip3 install scapy netfilterqueue
nohup python3 gen.py -q 100 -w 1 -s 7 -c 0 -n 7 &
iptables -I OUTPUT -p tcp --sport 443 -j NFQUEUE --queue-num 100
iptables -I OUTPUT -p tcp --sport 80 -j NFQUEUE --queue-num 100
echo "gen.py install finish, please verify it with [ps -ef|grep gen]"