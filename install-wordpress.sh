#!/bin/bash
if [ `whoami` != "root" ]; then
    echo "sudo提权或使用root用户权限执行"
    exit 1
fi

if [ ! -f "/etc/debian_version" ]; then
    echo "老板，请使用ubuntu系统"
    exit 1
fi
local_ip=$(ifconfig eth0 | grep '\<inet\>'| grep -v '127.0.0.1' | awk '{ print $2}' | awk 'NR==1')

rm -rf /opt/wordpress /var/www/html/wordpress

mkdir -p /opt/wordpress
cd /opt/wordpress
wget https://cn.wordpress.org/latest-zh_CN.tar.gz
tar -zxvf latest-zh_CN.tar.gz -C /var/www/html
apt update && apt upgrade -y
apt install php7.4-mbstring php7.4-gd php7.4-mysql php7.4-xml php7.4-curl -y
rm latest-zh_CN.tar.gz

if [ -f /usr/bin/mysql ];
then
  echo "MySQL 已经存在，请自行使用已有数据库"
else
  apt install mysql-server -y
  mysql --user="root" --password="password" -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'password';"
  mysql --user="root" --password="password" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
  mysql --user="root" --password="password" -e "CREATE DATABASE IF NOT EXISTS wordpress DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  echo "数据库用户名：root"
  echo "数据库密码：password"
fi
chown -R www-data:www-data /var/www/html/wordpress

echo "wordpress站点已安装，请浏览器打开 http://$local_ip/wordpress 进入设置。"
echo ""
echo "如遇到问题，请在社区bbs.histb.com提出。"
