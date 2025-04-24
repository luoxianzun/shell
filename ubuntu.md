
# 同步时间
wget -O setup_time.sh https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/ubuntu/setup_time.sh && sh setup_time.sh

# 初始化安装
wget -O lemp.sh https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/ubuntu/lemp.sh && sh lemp.sh

# 配置数据库
wget -O db_setup.sh https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/ubuntu/db_setup.sh && sh db_setup.sh

# 安装samba
wget -O samba.sh https://raw.githubusercontent.com/luoxianzun/shell/refs/heads/main/ubuntu/samba.sh && sudo sh samba.sh www SAMBAPassword