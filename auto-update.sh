#!/bin/bash
#Script for autmatically keeping Zabbix Proxies up to date

#Copy current version of GIthub repo and overwrite existing
git clone https://github.com/Iserv-Group/Zabbix-Proxy.git ~/temp
mv ~/temp/ ~/Zabbix-Proxy/
#Copy all scripts to Zabbix docker folder
cp -r ~/Zabbix-Proxy/externalscripts/ /docker/proxy/
#Pull Current version of Proxy docker container and rebuild the container 
docker-compose -f /docker/compose/proxy/docker-compose.yml pull
docker-compose -f /docker/compose/proxy/docker-compose.yml up -d

