#!/bin/bash

disk_t=70

#sudo /usr/local/bin/passenger-status | head
cpu_nos=`nproc`
uptime=`uptime | awk '{print $3,$4,$5}'|sed 's/.$//'`
load_avg=`uptime | awk '{print $8,$9,$10,$11,$12}'`
mem_usage=`free -h | awk '{print (NR==1?"Type":""), $1, $2, $3, (NR==1?"":$4)}' | column -t`
cpu_usage=$(top -bn 2 -d 0.01 | grep '^%Cpu' | tail -n 1 | gawk '{print $2+$4+$6}')

num=2
fil=$(($num + 1))
t_cpu=$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -$fil)
t_mem=$(ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -$fil)
 
load_1=$(awk '{print $1}'< /proc/loadavg)
load_2=$(awk '{print $2}'< /proc/loadavg)
load_3=$(awk '{print $3}'< /proc/loadavg)

##Passenger memory status##
echo "##------Passenger status------##"
sudo /usr/local/bin/passenger-status|head|grep -A3 "^Max pool size"
echo -e "\n"

#echo -e "\n"
echo "##------Uptime------##"
echo "$uptime"
#echo -e "\n"

echo "##------Load Avg----##"
echo "$load_avg"
#echo -e "\n"

echo "##----CPU Cores----##"
echo No: of CPUs / CPU Cores: "$cpu_nos"
#echo -e "\n"

echo "##----Relative load----##"
echo | awk -v c="${cpu_nos}" -v l="${load_1}" '{print "Relative load for last 1 minute is " l*100/c "%"}'
echo | awk -v c="${cpu_nos}" -v l="${load_2}" '{print "Relative load for last 5 minutes is " l*100/c "%"}'
echo | awk -v c="${cpu_nos}" -v l="${load_3}" '{print "Relative load for last 15 minutes is " l*100/c "%"}'

echo -e "\n"
echo "##----CPU usage----##"
echo "$cpu_usage"%
echo "##----Top $num CPU consuming process----##"
echo "$t_cpu"

echo -e "\n"
echo "##----Mem usage----##"
echo "$mem_usage"
#echo -e "\n"

echo "##----Top $num Mem consuming process----##"
echo "$t_mem"
echo -e "\n"

echo "##----Disk Usage higher than $disk_t%----##"
df -h | grep "^Filesystem"
for i in `df -h | grep -v "^Filesystem" | awk '{print $5}'`; do
size=${i%"%"}
#echo $size
if (( "$size" >= "$disk_t" )); then
    df -h | grep $size%
fi
done
