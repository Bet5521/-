#!/bin/bash
# Only support Debian 10

if [ `whoami` != "root" ]; then
    echo "sudo or root is required!"
    exit 1
fi

if [ ! -f "/etc/debian_version" ]; then
    echo "Boss, do you want to try debian?"
    exit 1
fi
check_dockerimage(){
  docker inspect qinglong -f '{{.Name}}' > /dev/null
  if [ $? -eq 0 ] ;then
    echo "青龙镜像已存在，请不要重复安装"
  else
	echo "开始安装2.11版本青龙面板！"
    install_dockerimage
    echo 123 > /etc/qlinstalled
    echo "青龙面板已经安装，首次安装请1分钟后浏览器打开 http://$local_ip:5700 进入设置"
  fi
}
install_dockerimage(){
docker pull whyour/qinglong:latest
docker run -dit \
  -v /opt/ql/config:/ql/config \
  -v /opt/ql/log:/ql/log \
  -v /opt/ql/db:/ql/db \
  -v /opt/ql/scripts:/ql/scripts \
  -v /opt/ql/jbot:/ql/jbot \
  -v /opt/ql/ninja:/ql/ninja
  -v /dev:/dev \
  -p 5700:5700 \
  --name qinglong \
  --hostname qinglong \
  --restart unless-stopped \
  whyour/qinglong:2.11
}
local_ip=$(ifconfig eth0 | grep '\<inet\>'| grep -v '127.0.0.1' | awk '{ print $2}' | awk 'NR==1')
if [ -x "$(command -v docker)" ]; then
  echo "docker已安装." >&2
  check_dockerimage
else
  apt update && apt install docker.io -y
  check_dockerimage
fi
sleep 1
echo "如有疑问，请访问 https://bbs.histb.com 获得相关教程"
