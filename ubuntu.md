
# 初始化 [修改ssh端口、system update、svn install]
wget -O init.sh https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/ubuntu/init.sh && sh init.sh 18188

# 同步时间
wget -O setup_time.sh https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/ubuntu/setup_time.sh && sh setup_time.sh

URL=https://www.aapanel.com/script/install_7.0_en.sh && if [ -f /usr/bin/curl ];then curl -ksSO "$URL" ;else wget --no-check-certificate -O install_7.0_en.sh "$URL";fi;bash install_7.0_en.sh aapanel

# 安装samba
wget -O samba.sh https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/ubuntu/samba.sh && sudo sh samba.sh www SAMBAPassword