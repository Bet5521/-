#!/bin/bash
# Only support Debian 10

portainer_version="2.14.0"

if [ `whoami` != "root" ]; then
    echo "sudo or root is required!"
    exit 1
fi

if [ ! -f "/etc/debian_version" ]; then
    echo "Boss, do you want to try debian?"
    exit 1
fi

check_dockerimagep(){
  docker inspect Portainer -f '{{.Name}}' > /dev/null
  if [ $? -eq 0 ] ;then
    echo "镜像已存在，请不要重复安装"
  else
    install_dockerimagep
    echo 123 > /etc/pdinstalled
    echo "容器管理工具已经安装，浏览器打开 http://$local_ip:9000 进入设置"
  fi
}

install_dockerimagep(){
	docker run -dit \
	--name Portainer \
	--restart=always \
	--network=host \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v /opt/Portainer:/data \
	-v /opt/Portainer/portainer_public:/public \
	-v /dev:/dev \
	portainer/portainer-ce:${portainer_version}
}
local_ip=$(ifconfig eth0 | grep '\<inet\>'| grep -v '127.0.0.1' | awk '{ print $2}' | awk 'NR==1')
if [ ! -d /opt/Portainer/portainer_public ] ;then
  mkdir -p /opt/Portainer
  wget --no-check-certificate https://dl.ecoo.top/update/soft_init/portainer-ce-cn-${portainer_version}.zip -P /opt/Portainer && echo "Successed download chinese language package"
  if [ ! -f /opt/Portainer/portainer-ce-cn-${portainer_version}.zip ]; then 
    echo "donwload chinese language package failed" && exit
  fi
  unzip -o /opt/Portainer/portainer-ce-cn-${portainer_version}.zip -d /opt/Portainer
  rm -f /opt/Portainer/portainer-ce-cn-${portainer_version}.zip
fi
if [ -x "$(command -v docker)" ]; then
  echo "docker已安装." >&2
  check_dockerimagep
else
  apt update && apt install docker.io -y
  check_dockerimagep
fi
sleep 1
echo "如有疑问，请访问 https://bbs.histb.com 获得相关教程"
