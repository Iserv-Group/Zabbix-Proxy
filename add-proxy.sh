#!/bin/bash


#Gather credentials for logging into the Zabbix API
echo "Please enter a Zabbix Super Admin username"
read username
echo "Please enter the password for the Zabbix Super Admin"
read -s password

#Create the Authentication Payload for logging into the Zabbix API
payload=$(echo '{"jsonrpc":"2.0","method":"user.login","params":{ "user":"USERNAME","password":"PWD"},"auth":null,"id":0}' | awk -v srch="PWD" -v repl="$password" '{ sub(srch,repl,$0); print $0 }' | awk -v srch="USERNAME" -v repl="$username" '{ sub(srch,repl,$0); print $0 }')
#Login to the Zabbix API and save the the results
login=$(curl -X POST -H 'Content-type:application/json' -d "$payload" https://zabbix.iserv.net/api_jsonrpc.php)
auth=$(echo $login | jq -r .result)
login_id=$(echo $login | jq -r .id)



