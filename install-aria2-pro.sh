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
  docker inspect aria2-pro -f '{{.Name}}' > /dev/null
  if [ $? -eq 0 ] ;then
    echo "aria2-pro镜像已存在，请不要重复安装"
  else
	echo "开始安装aria2-pro！"
    install_dockerimage
    echo 123 > /etc/aria2-pro-installed
    echo "aria2-pro已经安装，RPC地址 http://$local_ip:6800 ,连接密钥passw0rd"
  fi
}
install_dockerimage(){
docker pull p3terx/aria2-pro:latest
docker run -d \
    --name aria2-pro \
    --restart unless-stopped \
    --log-opt max-size=1m \
    --network host \
    -e PUID=$UID \
    -e PGID=$GID \
    -e RPC_SECRET=passw0rd \
    -e RPC_PORT=6800 \
    -e LISTEN_PORT=6888 \
    -v /opt/aria2-pro/config:/config \
    -v /opt/aria2-pro/downloads:/downloads \
    p3terx/aria2-pro
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
