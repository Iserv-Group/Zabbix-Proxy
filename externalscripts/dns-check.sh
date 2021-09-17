#!/bin/bash
#dnslookup
#DNS lookup scripts for Zabbix monitor. Conditional return
# of 1=success | 0=failed

host -W 2 $1 $2 2>/dev/null | grep "has address" | wc -l
