#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
wget -O geneva.py http://d.16idc.com/shell/geneva.py
yum install -y python3 python3-devel gcc gcc-c++ git libnetfilter* libffi-devel
pip3 install --upgrade pip
pip3 install scapy netfilterqueue
nohup python3 geneva.py -q 100 -w 17 &
nohup python3 geneva.py -q 101 -w 4 &
iptables -I OUTPUT -p tcp --sport 80 --tcp-flags SYN,RST,ACK,FIN,PSH SYN,ACK -j NFQUEUE --queue-num 100
iptables -I OUTPUT -p tcp --sport 443 --tcp-flags SYN,RST,ACK,FIN,PSH SYN,ACK -j NFQUEUE --queue-num 101
echo "geneva.py install finish, please verify it with [ps -ef|grep geneva]"