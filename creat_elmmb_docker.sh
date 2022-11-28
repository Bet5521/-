
OUT_ALERT() {
    echo -e "${CYELLOW} $1 ${CEND}"
}

DOCKER_INSTALL() {
    docker_exists=$(docker version 2>/dev/null)
    if [[ ${docker_exists} == "" ]]; then
        OUT_ALERT "[?] 正在安装docker"

        curl -fsSL get.docker.com | bash 
    fi
if false;then
    docker_compose_exists=$(docker-compose version 2>/dev/null)
    if [[ ${docker_compose_exists} == "" ]]; then
        OUT_ALERT "[?] 正在安装docker-compose"

        curl -L --fail https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose && \
	    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
    fi
 fi   
}


DOCKER_UP() {
    chmod +x /elmmb
    cd /elmmb
	
	docker stop elmmb
	
	docker rm elmmb
	
	docker rmi elmmb

    if [ ! -f "/elmmb/Dockerfile" ]; then
        wget https://ghproxy.com/https://raw.githubusercontent.com/lu0b0/ELM/main/images/Dockerfile -O /elmmb/Dockerfile
    fi
    
    if [[ ${version} != "latest" ]];then

    	wget https://ghproxy.com/https://github.com/lu0b0/ELM/releases/download/$version/elmmb -O /elmmb/elmmb
    fi
    if [[ ${version} == "latest" ]];then
    	wget https://ghproxy.com/https://github.com/lu0b0/ELM/releases/download/$(curl -Ls "https://api.github.com/repos/lu0b0/ELM/releases/latest" | 
	grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')/elmmb -O /elmmb/elmmb
    fi	
    chmod -R 777 /elmmb
	
    docker build -t='elmmb' .
}

echo -e $"\n欢迎使用饿了么登陆面板Docker一键部署脚本"
read -p "输入Y/y确认安装 跳过安装请直接回车:  " CONFIRM
CONFIRM=${CONFIRM:-"N"}
read -p $'\n 输入版本号(默认最新版)：' version
version=${version:-"latest"}
read -p "是否需要配置授权config文件（默认配置Y）" cfg
cfg=${cfg:-"Y"}
if [[ -f "/elmmb/Config.json"  ]]; then
	echo -e $"\n已发现存在Config文件，是否确认重新配置？（默认N）第二次"
	cfg=${cfg:-"N"}
fi
##if [[ ! -f "/elmmb/Config.json"  ]]; then
	
##fi
if [[ ${CONFIRM} == "Y" || ${CONFIRM} == "y" ]];then
	if [ ! -d "/elmmb" ]; then
		mkdir /elmmb
	fi
	if [[ ${cfg} == "Y" || ${cfg} == "y" ]];then
		if [[ -f "/elmmb/Config.json"  ]]; then
	echo -e $"\n已发现存在Config文件，是否确认重新配置？（默认N）"
	cfg2=${cfg2:-"N"}
		fi
	fi	
		if [[ ${cfg2} == "Y" || ${cfg2} == "y" ]];then
			read -p $'\n 输入授权码: ' sqm
			sqm=${sqm:-""}
			read -p $'\n 输入青龙url: 例：（http://192.168.0.1:5700）：' qlurl
			qlurl=${qlurl:-""}

			read -p $'\n 输入容器CLIENTID: ' CLIENTID
			CLIENTID=${CLIENTID:-""}

			read -p $'\n 输入容器SECRET: ' SECRET
			SECRET=${SECRET:-""}
	
			read -p $'\n 输入wxpusher推送的app_token 获取地址：https://wxpusher.zjiecode.com/admin (不设置推送按回车): ' wxpusher
			wxpusher=${wxpusher:-""}

	echo "{
		\"Authorization\":\"$sqm\",
		\"Title\": \"饿了么\",
		\"Announcement\": \"公告\",
		\"wxpusher_token\":\"$wxpusher\",
		\"Config\": [
			{
				\"QLkey\": 1,
				\"QLName\": \"容器1\",
				\"QLurl\": \"$qlurl\",
				\"QL_CLIENTID\": \"$CLIENTID\",
				\"QL_SECRET\": \"$SECRET\",
				\"QL_CAPACITY\": 40
			}
		]
	}" > /elmmb/Config.json
		fi
	DOCKER_INSTALL
	DOCKER_UP
fi
read -p "输入容器映射端口: （回车默认为3000）" pp
pp=${pp:-"3000"}
if [[ ${pp} != "3000" || ${pp} != "3000" ]];then
	eval "docker run -dit   -v /elmmb:/etc/elm   -p $pp:3000   --name elmmb   --hostname elmmb   --restart unless-stopped    --restart always   elmmb:latest"
else	
	eval "docker run -dit   -v /elmmb:/etc/elm   -p 3000:3000   --name elmmb   --hostname elmmb   --restart unless-stopped    --restart always   elmmb:latest"
fi

exit 0
