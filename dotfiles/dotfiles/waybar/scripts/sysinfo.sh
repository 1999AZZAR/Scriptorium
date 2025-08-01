#!/bin/bash
CPU=$(top -bn1 | grep '%Cpu' | awk '{print 100 - $8}')
MEM=$(free -m | awk '/Mem:/ { printf("%d", $3*100/$2) }')
GPU=$(radeontop -l 1 -d - | grep -o 'gpu [0-9]*' | awk '{print $2}')
echo -e "\uf2db ${CPU%%%}%   \uf1b0 ${GPU%%%}%   \uf108 ${MEM%%%}%"
