#!/bin/bash
#定义字体颜色
RE='\033[1;31m' # Red color code
GR='\033[1;32m' # Green color code
BL='\033[1;34m' # Blue color code
PU='\033[1;35m' # Purple(紫) color code
SK='\033[1;36m' # SkyBlue(天蓝) color code
NC='\033[0m'    # Reset color to normal
 
echo '解压tar包并给与docker权限...'
tar -xvf ./package/docker* -C ./package && chmod 777 ./package/docker/*
echo '将docker移到/usr/bin目录下...'
cp -r ./package/docker/* /usr/bin/
echo '将docker.service移到/etc/systemd/system/目录并给与权限...' 
cp -r ./conf/docker.service /etc/systemd/system/ && chmod 777 /etc/systemd/system/docker.service
echo '######################'
echo '创建docker工作目录并创建daemon.json配置文件...'
mkdir -p /etc/docker && mkdir -p /data/app/dockerWork
tee /etc/docker/daemon.json <<-'EOF'
{
        "data-root":"/data/app/dockerWork",
        "insecure-registries": ["ss.suwell.com"],
        "registry-mirrors": ["https://geuj9lut.mirror.aliyuncs.com"]
}
EOF
echo '重新加载配置文件并重启docker...'
systemctl daemon-reload && systemctl restart docker
echo '设置docker开机自启动...'
systemctl enable docker.service
echo '######## docker版本信息 ########'
docker info
echo '将docker-compose移到/usr/bin/目录...'
cp ./conf/docker-compose* /usr/local/bin/docker-compose && chmod 777 /usr/local/bin/docker-compose
 
echo -e "${PU}######## 验证docker安装结果... ########${NC}"
if ! docker version; then
echo -e "${RE}docker 安装失败...${NC}"
exit -1
fi
echo -e "${GR}docker安装成功！！！${NC}"
 
echo -e "${PU}######## 验证docker-compose安装结果... ########${NC}"
if ! docker-compose -v; then
echo -e "${RE}docker-compose 安装失败...${NC}"
exit -1
fi
echo -e "${GR}docker-compose 安装成功！！！${NC}"
 
rm -rf ./package/docker
