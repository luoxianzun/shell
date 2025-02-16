#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#Change ssh port
SSHPORT=$1

if [ -z $SSHPORT ]; then
 echo "SSH Port must input."
 exit
fi

sed -i "s/#Port 22/Port ${SSHPORT}/" /etc/ssh/sshd_config

systemctl restart firewalld

firewall-cmd --zone=public --add-port=$SSHPORT/tcp --permanent
firewall-cmd --reload
sudo dnf install policycoreutils-python-utils
semanage port -a -t ssh_port_t -p tcp $SSHPORT
systemctl restart sshd.service

#Update System
sudo dnf update

#Install SVN
sudo dnf remove subversion
sudo dnf install subversion
svn --version