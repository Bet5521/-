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
  docker inspect homeassistant -f '{{.Name}}' > /dev/null
  if [ $? -eq 0 ] ;then
    echo "homeassistant镜像已存在，请不要重复安装"
  else
    mkdir -p /opt/ha
    install_dockerimage
    echo 123 > /etc/hainstalled
    echo "homeassistant已经安装，首次安装请1分钟后浏览器打开http://$local_ip:8123进入设置"
  fi
}

install_dockerimage(){
docker pull linuxserver/homeassistant:latest
docker run -dit \
  -v /opt/ha:/config \
  -v /dev:/dev \
  -p 8123:8123 \
  --name homeassistant \
  --hostname homeassistant \
  --restart unless-stopped \
  linuxserver/homeassistant:latest
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
