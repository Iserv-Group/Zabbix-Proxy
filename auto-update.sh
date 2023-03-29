#!/bin/bash
tag="latest" #Set tag that proxies will use
#Script for autmatically keeping Zabbix Proxies up to date
#Copy current version of Github repo
git clone https://github.com/Iserv-Group/Zabbix-Proxy.git ~/temp
cp -fr ~/temp/* -t ~/Zabbix-Proxy
rm -fr ~/temp/
#Copy all scripts to Zabbix docker folder
cp -r ~/Zabbix-Proxy/externalscripts/ /docker/proxy/
#Set Proxy Tag
image='    image: zabbix\/zabbix-proxy-sqlite3:'$tag
sed -i "s/.*zabbix-proxy-sqlite3.*/$image/" /docker/compose/proxy/docker-compose.yml
#Pull Current version of Proxy docker container and rebuild the container 
docker-compose -f /docker/compose/proxy/docker-compose.yml pull
docker-compose -f /docker/compose/proxy/docker-compose.yml up -d
#Reset new version of this update script to executable
chmod +X ~/Zabbix-Proxy/auto-update.sh

