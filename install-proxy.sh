#!/bin/bash
#Prompt for variables
	read -a tls_id -p "Enter 3 digit TLS ID: "; echo
	echo "Enter the Hostname that will be used in Zabbix. Must be uniq"
	read -a hostname -p "hostname: "; echo
	echo "Enter Zabbix server Hostname or IP"
	read -a zbx_srv -p "Zabbix Server: "; echo
#Install docker and docker compose 
	apt install docker docker-compose -y
#Find current user
	user=$(who | awk '{print $1}' | uniq)
#Add current user to docker group
	usermod -a -G docker $user
#Create directories for docker
	mkdir /docker 
	mkdir /docker/proxy
	mkdir /docker/proxy/externalscripts
	mkdir /docker/proxy/enc
	mkdir /docker/compose
	mkdir /docker/compose/proxy
#Change permisions to current user and docker group
	chown -R $user:docker /docker
#Generate TLS key for encrypted connection
	tls_key=$(openssl rand -hex 32)
	echo $tls_key > /docker/proxy/enc/tls.psk
#Replace variables in docker compose file
	cat TEMPLATE-docker-compose.yml | sed "s/PSK 111/PSK $tls_id/g" | sed "s/example-hostname/$hostname/g" | sed "s/example.host.com/$zbx_srv/g" > /docker/compose/proxy/docker-compose.yml
#Start the docker container
docker-compose -f /docker/compose/proxy/docker-compose.yml up -d
#Install Zabbix agent
	apt install zabbix-agent -y
#Edit Zabbix config file
	cat /etc/zabbix/zabbix_agentd.conf | sed "s/ServerActive=127.0.0.1/ServerActive=zabbix.iserv.net/g" | sed "s/# Hostname=/Hostname=$hostname/g" | sed 's/# TLSConnect=unencrypted/TLSConnect=psk/g' | sed "s/# TLSPSKIdentity=/TLSPSKIdentity=PSK $tls_id/g" | sed 's/# TLSPSKFile=/TLSPSKFile=\/docker\/proxy\/enc\/tls.psk/g' > /etc/zabbix/zabbix_agentd.conf
#Move Agent config file
	mv docker-simple.conf /etc/zabbix/zabbix_agentd.conf.d/docker-simple.conf
#Restart zabbix service
	service zabbix-agent restart
#Print Output for Zabbix configuration
	echo "Use these variables to add the Proxy/Host to Zabbix"
	echo "Proxy name: "$hostname
	echo "PSK identitiy: PSK "$tls_id
	echo "PSK: "$tls_key


