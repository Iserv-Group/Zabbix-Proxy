#!/bin/bash

test=$(curl -Is $1 | head -n 1 | awk -F ' ' '{print $2}')

if [ -z "$test" ];then
        echo "0"
elif [ "$test" -eq 200 ];then
        echo "1"
elif [ "$test" -eq 301 ];then
        echo "2"
elif [ "$test" == 403 ];then
        echo "3"
elif [ "$test" == 404 ];then
        echo "4"
elif [ "$test" == 500 ];then
        echo "5"
elif [ "$test" == 502 ];then
        echo "6"
elif [ "$test" == 503 ];then
        echo "7"
else
        echo "8"
fi