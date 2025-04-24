# 机器初始化，修改端口，更新svn CentOS 7
yum install -y wget && wget -O init.sh https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/init.sh && sh init.sh 18888

# 格式化硬盘、挂载硬盘
mkdir /www && mount /dev/sdb1 /www && echo "/dev/sdb1              /www                  ext4    defaults        0 0" >> /etc/fstab

# 格式化并挂载4T以上的磁盘
wget -O format_and_mount.sh   https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/format_and_mount.sh && sudo sh format_and_mount.sh

# 安装宝塔并安装软件，设置防火墙端口
URL=https://www.aapanel.com/script/install_7.0_en.sh && if [ -f /usr/bin/curl ];then curl -ksSO "$URL" ;else wget --no-check-certificate -O install_7.0_en.sh "$URL";fi;bash install_7.0_en.sh aapanel

# 安装Samba并做好映射
wget -O samba.sh https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/centos9/samba.sh && sudo sh samba.sh www SAMBAPassword

# CentOS9
dnf install -y wget && wget -O init.sh https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/centos9/init.sh && sh init.sh 18888

# 同步时间
wget -O setup_time.sh https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/centos9/setup_time.sh && sh setup_time.sh

# 移动节点执行以下脚本实现突破移动屏蔽
yum install -y wget && wget -O gen.sh https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/gen.sh && sh gen.sh

# CENTOS7 放通SSH端口 18888
firewall-cmd --zone=public --add-port=18888/tcp --permanent && firewall-cmd --reload && yum -y install policycoreutils-python && semanage port -a -t ssh_port_t -p tcp 18888 && systemctl restart sshd.service

# 默认服务器修改设置，修改挂载硬盘、修改密码
umount /dev/sda3 && mkdir /www && mount /dev/sda3 /www && rm -rf /a && sed -i 's|/a|/www|g' /etc/fstab && echo "DDDPassword123" | passwd --stdin root