#!/bin/bash
# scripts for photoalbum install

dl_mirrors=("https://dl.ecoo.top" "https://www.ecoo.top")

readonly COLOUR_RESET='\e[0m'
declare -A COLORS
COLORS=(
    ["red"]='\e[91m'
    ["green"]='\e[32;1m' 
    ["yellow"]='\e[33m'
    ["grey"]='\e[90m'
)
readonly GREEN_LINE=" ${COLORS[green]}─────────────────────────────────────────────────────$COLOUR_RESET\n"

printStr() {
    color=$1
    printf ${COLORS[${color}]}"$2"${COLOUR_RESET}"\n"
}

_exit() {
    exit_singal=$1
    shift
    [ "$exit_singal" != "0" ] && printStr red "$*" || printStr green "$*"
    exit $exit_singal
}

dl_get() {
    file_url=$1
    save_path=$2
    [ ! -d $save_path ] && mkdir -p $save_path
    for(( i=0;i<${#dl_mirrors[@]};i++));do
        echo "${dl_mirrors[i]}"
        wget --no-check-certificate ${dl_mirrors[i]}/${file_url} -P $save_path && printStr green "Successed download ${file_url}" && return
    done
    
    _exit 1 "Download $file_url failed"
}

dl_photoalbum() {
    if [ ! -d /opt/photoalbum ]; then
	printStr yellow "photoalbum: adding new directry"
	mkdir -p /opt/photoalbum
	dl_get "update/soft_init/photoalbum.tar.gz" /opt/photoalbum
	tar -zxvf /opt/photoalbum/photoalbum.tar.gz -C /opt/photoalbum 2>&1 > /dev/null 
	rm /opt/photoalbum/photoalbum.tar.gz
	printStr yellow "photoalbum: download successed"
	printf $GREEN_LINE
    fi
}

aoto_photoalbum() {
cat > /etc/systemd/system/photoalbum.service <<EOF
[Unit]
Description=photoalbum for histb
After=network.target

[Service]
ExecStart=/usr/sbin/phtoalbum-start.sh
Type=simple
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

cat > /usr/sbin/phtoalbum-start.sh <<EOF
#!/bin/bash
if [ -d /opt/photoalbum ]; then
    cd /opt/photoalbum
    node app.js 2>&1 > /dev/null
fi
exit 0
EOF

chmod +x /usr/sbin/phtoalbum-start.sh
}

prepare_nodejs() {
  if [ -f /etc/apt/sources.list.d/nodesource.list ]; then
  rm -r /etc/apt/sources.list.d/nodesource.list
  fi
  sudo apt-get -y install software-properties-common
  sudo add-apt-repository -y -r ppa:chris-lea/node.js
  sudo rm -f /etc/apt/sources.list.d/chris-lea-node_js-*.list
  sudo rm -f /etc/apt/sources.list.d/chris-lea-node_js-*.list.save
  KEYRING=/usr/share/keyrings/nodesource.gpg
  wget --quiet -O - https://deb.nodesource.com/gpgkey/nodesource.gpg.key | gpg --dearmor | sudo tee "$KEYRING" >/dev/null
  gpg --no-default-keyring --keyring "$KEYRING" --list-keys
  VERSION=node_16.x
  DISTRO="$(lsb_release -s -c)"
  echo "deb [signed-by=$KEYRING] https://deb.nodesource.com/$VERSION $DISTRO main" | sudo tee /etc/apt/sources.list.d/nodesource.list
  echo "deb-src [signed-by=$KEYRING] https://deb.nodesource.com/$VERSION $DISTRO main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list
}
setup_photoalbum() {
    if [ -f /opt/photoalbum/app.js ]; then
	printStr yellow "photoalbum: setup progress"
	cd /opt/photoalbum
	apt update && apt install nodejs -y
	npm install
	sleep 2
	systemctl enable photoalbum.service
	systemctl start photoalbum.service
	printStr yellow "photoalbum: setup successed"
	printStr yellow "photoalbum: 已经成功安装并运行"
	printStr yellow "photoalbum: 请访问你的网页8083端口"
	printf $GREEN_LINE
    fi
}

dl_photoalbum
aoto_photoalbum
prepare_nodejs
setup_photoalbum

_exit 0 "安装已完成 successed"
