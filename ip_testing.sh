#!/bin/bash
for a in $(seq 1 10);do
    ping -c 3 192.168.1.$a > /dev/null
    case $? in
        0)  
            echo "192.168.1.$a on";;
        1)  
            echo "192.168.1.$a off";;
    esac
done
