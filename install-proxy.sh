#!/bin/bash
#Check to see if script is running as root
if [ "$(id -u)" -ne 0 ]; then
        echo 'This script must be run by root' >&2
        exit 1
fi
#Prompt for variables
	read -a tls_id -p "Enter 3 digit TLS ID: "; echo
	echo "Enter the Hostname that will be used in Zabbix. Must be uniq"
	read -a hostname -p "hostname: "; echo
	echo "Enter Zabbix server Hostname or IP"
	read -a zbx_srv -p "Zabbix Server: "; echo
#Install docker and docker compose 
	echo "Installing required packages"
	apt install docker docker-compose jq zabbix-agent -y 1> /dev/null
#Find current user
	echo "Making user changes"
	user=$(who | awk '{print $1}' | uniq)
#Add current user to docker group
	usermod -a -G docker $user 1> /dev/null
#Create directories for docker
	echo "Making required directories"
	mkdir /docker 1> /dev/null
	mkdir /docker/proxy 1> /dev/null
	mkdir /docker/proxy/externalscripts 1> /dev/null
	mkdir /docker/proxy/enc 1> /dev/null
	mkdir /docker/compose 1> /dev/null
	mkdir /docker/compose/proxy 1> /dev/null
#Change permisions to current user and docker group
	chown -R $user:docker /docker 1> /dev/null
#Generate TLS key for encrypted connection
	tls_key=$(openssl rand -hex 32) 
	echo $tls_key > /docker/proxy/enc/tls.psk 
#Replace variables in docker compose file
	cat TEMPLATE-docker-compose.yml | sed "s/PSK 111/PSK $tls_id/g" | sed "s/example-hostname/$hostname/g" | sed "s/example.host.com/$zbx_srv/g" > /docker/compose/proxy/docker-compose.yml
#Start the docker container
docker-compose -f /docker/compose/proxy/docker-compose.yml up -d 1> /dev/null
#Edit Zabbix config file
	cat /etc/zabbix/zabbix_agentd.conf | sed "s/ServerActive=127.0.0.1/ServerActive=$zbx_srv/g" | sed "s/# Hostname=/Hostname=$hostname/g" | sed 's/# TLSConnect=unencrypted/TLSConnect=psk/g' | sed 's/# TLSAccept=unencrypted/TLSAccept=psk/g' | sed "s/# TLSPSKIdentity=/TLSPSKIdentity=PSK $tls_id/g" | sed 's/# TLSPSKFile=/TLSPSKFile=\/docker\/proxy\/enc\/tls.psk/g' > /etc/zabbix/zabbix_agentd.conf.tmp
	mv /etc/zabbix/zabbix_agentd.conf.tmp /etc/zabbix/zabbix_agentd.conf 1> /dev/null
#Move Agent config file
	cp docker-simple.conf /etc/zabbix/zabbix_agentd.conf.d/docker-simple.conf 1> /dev/null
#Restart zabbix service
	service zabbix-agent restart 1> /dev/null
#Print Output for Zabbix configuration
	echo "Use these variables to add the Proxy/Host to Zabbix"
	echo "Proxy name: "$hostname
	echo "PSK identitiy: PSK "$tls_id
	echo "PSK: "$tls_key


