#!/bin/bash
for i in $(seq 1 254);do ping 192.168.2.$i -c 2;done >> ping.txt
