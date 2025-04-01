#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#修改22端口 CentOS 9
SSHPORT=19198
sed -i "s/#Port 22/Port ${SSHPORT}/" /etc/ssh/sshd_config
systemctl restart firewalld
firewall-cmd --zone=public --add-port=$SSHPORT/tcp --permanent
firewall-cmd --reload
sudo dnf install policycoreutils-python-utils
semanage port -a -t ssh_port_t -p tcp $SSHPORT
systemctl restart sshd.service