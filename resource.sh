#!/usr/bin/env bash

value=0
mem_limit="60.00"
cpu_limit="50.00"
load_limit="1"
cpu_core=`nproc`

while [ "$value" = "0" ]; do
echo -e "\n"
read -r -p "Enter day of the month DD [01-31]:" date
read -r -p "Enter Start time in EST [HH:MM:SS/NA]: " start_time
read -r -p "Enter End time in EST [HH:MM:SS/NA]: " end_time

if [[ "$date" =~ ^(0[1-9]|[12][0-9]|3[01])$ ]]; then
   if [[ "$start_time" =~ ^(0[1-9]|1[0-2]):([0-5][0-9]):([0-5][0-9])$ && "$end_time" =~ ^(0[1-9]|1[0-2]):([0-5][0-9]):([0-5][0-9])$ ]]; then
      if [[ "$start_time" < "$end_time" ]]; then
      file_date=`sar -f /var/log/sa/sa$date | head -n 1 | awk '{print $4}'`
      echo -e "\nAverage resource utilization on $file_date between $start_time and $end_time"
      value=1
      sar -u -f /var/log/sa/sa$date -s $start_time -e $end_time | awk '/Average:/{printf("CPU Average: %.2f%\n"), 100 - $8}'
      sar -r -f /var/log/sa/sa$date -s $start_time -e $end_time | awk '/Average:/{printf("Memory Average: %.2f%\n"),(($3-$5-$6)/($2+$3)) * 100 }'
sar -q -f /var/log/sa/sa$date -s $start_time -e $end_time | awk '/Average:/{print "Load Average for last 1,5,15 Minutes: "$4,$5,$6}'
     echo -e "\nHigh memory usage (>$mem_limit%) during the given time span"
     sar -r -f /var/log/sa/sa$date -s $start_time -e $end_time | grep -a "%memused"
     for i in `sar -r -f /var/log/sa/sa$date -s $start_time -e $end_time | grep -vE "^Average|^Linux|kbmemfree|^$"|awk '{print $5}'`;do
      if (( $(echo "$i >= $mem_limit" |bc -l) )); then
      sar -r -f /var/log/sa/sa$date -s $start_time -e $end_time | grep -vE "^Average|^Linux|kbmemfree|^$"|grep -a "$i"
      fi
     done
     echo -e "\nHigh CPU usage (>$cpu_limit) during the given time span"
     sar -u -f /var/log/sa/sa$date -s $start_time -e $end_time | grep -a "%idle"
     for j in `sar -u -f /var/log/sa/sa$date -s $start_time -e $end_time | grep -Ev "^Linux|^Average:|%idle|^$"|awk '{print $9}'`;do
      if (( $(echo "$j <= $cpu_limit" |bc -l) )); then
      sar -u -f /var/log/sa/sa$date -s $start_time -e $end_time | grep -Ev "^Linux|^Average:|%idle|^$" | grep -a "$j"
      fi
     done
     echo -e "\nHigh load (>$load_limit) during the given time span"
     sar -q -f /var/log/sa/sa$date -s $start_time -e $end_time | grep -a "ldavg-1"
     for k in `sar -q -f /var/log/sa/sa$date -s $start_time -e $end_time | grep -vE "^Linux|^Average|^$|ldavg-1"|awk '{print $5}'`;do
      if (( $(echo "$k/$cpu_core >= $load_limit" |bc -l) )); then
      sar -q -f /var/log/sa/sa$date -s $start_time -e $end_time | grep -vE "^Linux|^Average|ldavg-1|^$" | grep -a "$k"
      fi
      done 
      else
      echo "End time must be greater than start time"
      fi
   elif [[ $start_time = "NA" && $end_time = "NA" ]]; then
      value=1
      read -r -p "Enter the time span in minutes [MM]:" time_span
      current_time=`date "+%H:%M:%S"`
      if [[ $time_span =~ ^[0-9]+$ ]]; then
      input_time=`date -d "$time_span minutes ago" "+%H:%M:%S"` 
      file_date=`sar -f /var/log/sa/sa$date | head -n 1 | awk '{print $4}'`
      echo -e "\nAverage resource utilization on $file_date between $input_time and $current_time"
      value=1
      sar -u -f /var/log/sa/sa$date -s $input_time -e $current_time | awk '/Average:/{printf("CPU Average: %.2f%\n"), 100 - $8}'
      sar -r -f /var/log/sa/sa$date -s $input_time -e $current_time | awk '/Average:/{printf("Memory Average: %.2f%\n"),(($3-$5-$6)/($2+$3)) * 100 }'
      sar -q -f /var/log/sa/sa$date -s $input_time -e $current_time | awk '/Average:/{print "Load Average for last 1,5,15 Minutes: "$4,$5,$6}'
     echo -e "\nHigh memory usage (>$mem_limit%) during the given time span"
     sar -r -f /var/log/sa/sa$date -s $input_time -e $current_time | grep -a "%memused"
     for i in `sar -r -f /var/log/sa/sa$date -s $input_time -e $current_time | grep -vE "^Average|^Linux|kbmemfree|^$"|awk '{print $5}'`;do
      if (( $(echo "$i >= $mem_limit" |bc -l) )); then
      sar -r -f /var/log/sa/sa$date -s $input_time -e $current_time | grep -vE "^Average|^Linux|kbmemfree|^$"|grep -a "$i"
      fi
     done
     echo -e "\nHigh CPU usage (>$cpu_limit) during the given time span"
     sar -u -f /var/log/sa/sa$date -s $input_time -e $current_time | grep -a "%idle"
     for j in `sar -u -f /var/log/sa/sa$date -s $input_time -e $current_time | grep -Ev "^Linux|^Average:|%idle|^$"|awk '{print $9}'`;do
      if (( $(echo "$j <= $cpu_limit" |bc -l) )); then
      sar -u -f /var/log/sa/sa$date -s $input_time -e $current_time | grep -Ev "^Linux|^Average:|%idle|^$" | grep -a "$j"
      fi
     done
     echo -e "\nHigh load (>$load_limit) during the given time span"
     sar -q -f /var/log/sa/sa$date -s $input_time -e $current_time | grep -a "ldavg-1"
     for k in `sar -q -f /var/log/sa/sa$date -s $input_time -e $current_time | grep -vE "^Linux|^Average|^$|ldavg-1"|awk '{print $5}'`;do
      if (( $(echo "$k/$cpu_core >= $load_limit" |bc -l) )); then
      sar -q -f /var/log/sa/sa$date -s $input_time -e $current_time | grep -vE "^Linux|^Average|ldavg-1|^$" | grep -a "$k"
      fi
      done      
      else
        echo "Invalid time span! Use <MM> format!"
      fi
   else  
      echo "Invalid time! Use <HH:MM:SS> format!"
   fi
else
   echo "Invalid date! Use <DD> format!"
fi
done
