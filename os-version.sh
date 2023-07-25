#!/bin/bash
USERNAME=root
read -r -p "Enter the full path of file containing IP list:" ip_list
for HOSTNAME in `cat $ip_list` ; do
    ssh -l ${USERNAME} ${HOSTNAME} "echo "$HOSTNAME : "|tr -d '\n';grep -i "^version=" /etc/os-release"
done
