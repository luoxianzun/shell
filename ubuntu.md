
# 初始化 [修改ssh端口、system update、svn install]
wget -O init.sh https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/ubuntu/init.sh && sh init.sh 18188

# 同步时间
wget -O setup_time.sh https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/ubuntu/setup_time.sh && sh setup_time.sh

# 安装samba
wget -O samba.sh https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/ubuntu/samba.sh && sudo sh samba.sh www SAMBAPassword