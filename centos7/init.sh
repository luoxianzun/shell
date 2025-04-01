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

firewall-cmd --zone=public --add-port=$SSHPORT/tcp --permanent && firewall-cmd --reload && yum -y install policycoreutils-python && semanage port -a -t ssh_port_t -p tcp $SSHPORT && systemctl restart sshd.service

#upgrade SVN version
yum remove subverson
sudo tee /etc/yum.repos.d/wandisco-svn.repo <<-'EOF'
[WandiscoSVN]
name=Wandisco SVN Repo
baseurl=http://opensource.wandisco.com/centos/7/svn-1.8/RPMS/$basearch/
enabled=1
gpgcheck=0
EOF
yum clean all && yum install subversion -y && svn --version

#upgrade yum
yum update